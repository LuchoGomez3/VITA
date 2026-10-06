import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/brick/stores/livestock_sale_brick_store.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:frontend_mayoral/demo/demo_bootstrap.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/mappers/livestock_sale_brick_mapper.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory testDirectory;
  late String sqlitePath;
  late String queuePath;
  late AppBrickRepository repository;
  late BrickLivestockSaleStore store;
  late Completer<Request> firstRemoteRequest;
  late Completer<void> allowFirstRemoteResponse;

  setUpAll(() async {
    sqfliteFfiInit();
    testDirectory = await Directory.systemTemp.createTemp(
      'vita_livestock_sale_store_test_',
    );
    sqlitePath = path.join(testDirectory.path, 'brick.sqlite');
    queuePath = path.join(testDirectory.path, 'queue.sqlite');
    firstRemoteRequest = Completer<Request>();
    allowFirstRemoteResponse = Completer<void>();
    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: queuePath,
      localDatabaseFactory: databaseFactoryFfi,
      tokenProvider: const _TokenProvider(),
      client: MockClient((request) async {
        if (!firstRemoteRequest.isCompleted) {
          firstRemoteRequest.complete(request);
          await allowFirstRemoteResponse.future;
        }
        // Un 5xx representa falta temporal de servicio: Brick conserva el POST
        // para reintentar y el alta local debe seguir confirmada para la UX.
        return Response(
          '{"success":false,"errors":[]}',
          503,
          request: request,
        );
      }),
    );
    repository = AppBrickRepository.instance;
    BrickLivestockSaleStore.configure(repository);
    store = BrickLivestockSaleStore.instance;
  });

  tearDownAll(() async {
    await store.dispose();
    await databaseFactoryFfi.deleteDatabase(sqlitePath);
    await databaseFactoryFfi.deleteDatabase(queuePath);
    if (testDirectory.existsSync()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('guarda venta y baja animales antes de enviar el POST', () async {
    await repository.upsertLocal(_animal('animal-a'));
    await repository.upsertLocal(_animal('animal-b'));

    final saved = await store.saveSale(
      _sale('sale-a', const ['animal-a', 'animal-b']),
    );

    expect(saved.syncStatus, BrickLivestockSaleSyncStatus.pending);
    final storedSales = await repository.getLocal<BrickLivestockSaleModel>();
    expect(storedSales.where((sale) => sale.localId == 'sale-a'), hasLength(1));
    final storedAnimals = await repository.getLocal<BrickAnimalModel>();
    final sold = storedAnimals.where(
      (animal) => const {'animal-a', 'animal-b'}.contains(animal.localId),
    );
    expect(
      sold.every(
        (animal) => animal.status == 'vendido' && animal.syncStatus == BrickAnimalSyncStatus.pending,
      ),
      isTrue,
    );

    final request = await firstRemoteRequest.future.timeout(
      const Duration(seconds: 5),
    );
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    expect(request.url.path, '/api/v1/ventas');
    expect(body['id'], 'sale-a');

    final queueDatabase = await databaseFactoryFfi.openDatabase(queuePath);
    final queuedRequests = await queueDatabase.query('HttpJobs');
    await queueDatabase.close();
    expect(queuedRequests, hasLength(1));
    expect(queuedRequests.single['body'], contains('"id":"sale-a"'));
    allowFirstRemoteResponse.complete();
  });

  test('rechaza una segunda venta y no persiste un estado parcial', () async {
    await expectLater(
      store.saveSale(_sale('sale-duplicate', const ['animal-a'])),
      throwsA(
        isA<LivestockSaleLocalException>().having(
          (error) => error.code,
          'code',
          LivestockSaleLocalErrorCode.animalNotActive,
        ),
      ),
    );

    final storedSales = await repository.getLocal<BrickLivestockSaleModel>();
    expect(
      storedSales.where((sale) => sale.localId == 'sale-duplicate'),
      isEmpty,
    );
  });

  test('rechaza animales de otro establecimiento sin guardar la venta', () async {
    await repository.upsertLocal(
      _animal('animal-other', establishmentId: 'other-establishment'),
    );

    await expectLater(
      store.saveSale(_sale('sale-other', const ['animal-other'])),
      throwsA(
        isA<LivestockSaleLocalException>().having(
          (error) => error.code,
          'code',
          LivestockSaleLocalErrorCode.differentEstablishment,
        ),
      ),
    );

    final storedSales = await repository.getLocal<BrickLivestockSaleModel>();
    expect(storedSales.where((sale) => sale.localId == 'sale-other'), isEmpty);
  });

  test('sincroniza venta y animales cuando backend acepta', () async {
    await store.applySyncResult(
      const BackendSyncResult(
        resourcePath: '/api/v1/ventas',
        localId: 'sale-a',
        synchronized: true,
      ),
    );

    final storedSales = await repository.getLocal<BrickLivestockSaleModel>();
    final sale = storedSales.singleWhere((item) => item.localId == 'sale-a');
    expect(sale.syncStatus, BrickLivestockSaleSyncStatus.synchronized);
    final storedAnimals = await repository.getLocal<BrickAnimalModel>();
    final animals = storedAnimals.where(
      (animal) => const {'animal-a', 'animal-b'}.contains(animal.localId),
    );
    expect(
      animals.every(
        (animal) => animal.status == 'vendido' && animal.syncStatus == BrickAnimalSyncStatus.synchronized,
      ),
      isTrue,
    );
  });

  test('un rechazo mantiene los animales vendidos y los marca para revision', () async {
    await repository.upsertLocal(_animal('animal-rejected'));
    await store.saveSale(
      _sale('sale-rejected', const ['animal-rejected']),
    );

    await store.applySyncResult(
      const BackendSyncResult(
        resourcePath: '/api/v1/ventas',
        localId: 'sale-rejected',
        synchronized: false,
        errorCode: 'animal_already_sold',
      ),
    );

    final storedSales = await repository.getLocal<BrickLivestockSaleModel>();
    final sale = storedSales.singleWhere(
      (item) => item.localId == 'sale-rejected',
    );
    expect(sale.syncStatus, BrickLivestockSaleSyncStatus.rejected);
    expect(sale.syncErrorCode, 'animal_already_sold');
    final animals = await repository.getLocal<BrickAnimalModel>();
    final animal = animals.singleWhere(
      (item) => item.localId == 'animal-rejected',
    );
    expect(animal.status, 'vendido');
    expect(animal.syncStatus, BrickAnimalSyncStatus.rejected);
    expect(animal.syncErrorCode, 'animal_already_sold');
  });

  test('el historial aísla establecimientos y cobrar no vuelve a modificar stock', () async {
    final sales = await store.getSales('establishment-id');
    expect(sales, isNotEmpty);
    expect(await store.getSales('another-establishment'), isEmpty);
    final current = LivestockSaleBrickMapper.fromBrick(sales.first);
    final collected = LivestockSaleBrickMapper.toBrick(
      current.copyWith(
        paymentCondition: LivestockSalePaymentCondition.total,
        initialPayment: LivestockSaleInitialPayment(
          id: 'payment-id',
          date: DateTime(2026, 10, 6),
          amountCents: current.totalAmountCents,
          method: LivestockSalePaymentMethod.cash,
          createdAt: DateTime.utc(2026, 10, 6),
          updatedAt: DateTime.utc(2026, 10, 6),
        ),
        updatedAt: DateTime.utc(2026, 10, 6),
      ),
    );
    final saved = await store.collectUnpaidSale(collected);
    expect(saved.paymentCondition, 'total');
    final stored = await store.getSales('establishment-id');
    expect(stored.where((sale) => sale.localId == current.id), hasLength(1));
    final animals = await repository.getLocal<BrickAnimalModel>();
    expect(
      animals
          .where((animal) => current.animalIds.contains(animal.localId))
          .every((animal) => animal.status == 'vendido'),
      isTrue,
    );
    await expectLater(store.collectUnpaidSale(collected), throwsA(isA<LivestockSaleCollectionException>()));
  });

  test('iniciar la demo reemplaza ventas anteriores por una venta sintética', () async {
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) async => null,
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
    );
    expect(await store.getSales('establishment-id'), isNotEmpty);
    await DemoBootstrap.initialize(reset: false);
    final sales = await repository.getLocal<BrickLivestockSaleModel>();
    expect(sales, hasLength(1));
    expect(sales.single.localId, DemoIds.sale);
    expect(sales.single.totalAmount, '1200000.00');
    expect(sales.single.paymentCondition, 'total');
    final animals = await repository.getLocal<BrickAnimalModel>();
    expect(animals.singleWhere((animal) => animal.localId == DemoIds.animalOne).status, 'activo');
    expect(animals.singleWhere((animal) => animal.localId == DemoIds.animalFour).status, 'vendido');
    await DemoBootstrap.initialize(reset: false);
    expect(await repository.getLocal<BrickLivestockSaleModel>(), hasLength(1));
  });
}

BrickAnimalModel _animal(
  String id, {
  String establishmentId = 'establishment-id',
}) {
  final timestamp = DateTime.utc(2026, 10, 3, 18, 30);
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: '982000412991416',
    visualTag: id,
    sex: BrickAnimalSex.female,
    breed: 'Angus',
    birthDate: DateTime.utc(2025, 3, 14),
    categoryId: 'category-id',
    lotId: 'lot-id',
    establishmentId: establishmentId,
    initialWeight: 320,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: timestamp,
    syncStatus: BrickAnimalSyncStatus.synchronized,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

BrickLivestockSaleModel _sale(String id, List<String> animalIds) {
  final timestamp = DateTime.utc(2026, 10, 3, 18, 30);
  return BrickLivestockSaleModel(
    localId: id,
    establishmentId: 'establishment-id',
    operationDate: DateTime(2026, 10, 3),
    buyerType: 'particular',
    buyerName: 'Juan',
    buyerLastName: 'Perez',
    isCompany: false,
    dteNumber: '001234567-9',
    saleType: 'al_bulto',
    totalAmount: '10000.00',
    animalIdsJson: jsonEncode(animalIds),
    paymentCondition: 'pendiente',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _TokenProvider implements BackendAccessTokenProvider {
  const _TokenProvider();

  @override
  Future<String?> getAccessToken() async => 'test-token';
}
