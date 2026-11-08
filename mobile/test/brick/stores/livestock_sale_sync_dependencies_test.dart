import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/livestock_sale_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/data/datasources/animal_detail_remote_data_source.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_detail_repository_impl.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory directory;
  late AppBrickRepository repository;
  late BrickAnimalStore animals;
  late BrickLivestockSaleStore sales;
  final knownAnimals = <String>{};
  final requests = <Request>[];
  var offline = true;
  var rejectSale = false;
  var rejectParent = false;
  Completer<void>? parentStarted;
  Completer<void>? allowParent;

  setUpAll(() async {
    sqfliteFfiInit();
    directory = await Directory.systemTemp.createTemp('vita_sale_dependencies_');
    await AppBrickRepository.configure(
      sqlitePath: path.join(directory.path, 'brick.sqlite'),
      offlineQueuePath: path.join(directory.path, 'queue.sqlite'),
      localDatabaseFactory: databaseFactoryFfi,
      tokenProvider: const _TokenProvider(),
      client: MockClient((request) async {
        requests.add(request);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (offline) return Response('{}', 503, request: request);
        if (request.url.path == '/api/v1/animales') {
          if (parentStarted?.isCompleted == false) parentStarted!.complete();
          await allowParent?.future;
          if (rejectParent) return Response('{"errors":[{"code":"invalid_animal"}]}', 409, request: request);
          knownAnimals.add(body['id'] as String);
          return Response(
            jsonEncode({
              'data': {...body, 'estado': 'activo'},
            }),
            200,
            request: request,
          );
        }
        final ids = (body['animal_ids'] as List<dynamic>).cast<String>();
        final accepted = !rejectSale && ids.every(knownAnimals.contains);
        return Response(
          jsonEncode(
            accepted
                ? {'data': body}
                : {
                    'errors': [
                      {'code': 'animals_not_available'},
                    ],
                  },
          ),
          accepted ? 200 : 409,
          request: request,
        );
      }),
    );
    repository = AppBrickRepository.instance;
    BrickAnimalStore.configure(repository);
    BrickLivestockSaleStore.configure(repository);
    BrickCategoriaStore.configure(repository);
    BrickLotStore.configure(repository);
    BrickPesajeStore.configure(repository);
    animals = BrickAnimalStore.instance;
    sales = BrickLivestockSaleStore.instance;
  });

  tearDownAll(() async {
    await sales.dispose();
    await animals.dispose();
    await databaseFactoryFfi.deleteDatabase(path.join(directory.path, 'brick.sqlite'));
    await databaseFactoryFfi.deleteDatabase(path.join(directory.path, 'queue.sqlite'));
    await directory.delete();
  });

  Future<BrickLivestockSaleModel> waitForSale(String id, BrickLivestockSaleSyncStatus status) async {
    for (var i = 0; i < 100; i++) {
      final stored = await repository.getLocal<BrickLivestockSaleModel>();
      final sale = stored.where((sale) => sale.localId == id).firstOrNull;
      if (sale?.syncStatus == status) return sale!;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    throw StateError('Sale did not reach $status');
  }

  test('espera el retry del alta y conserva dependencias al recrear el store', () async {
    final animal = _animal('offline-parent').copyWith(syncStatus: BrickAnimalSyncStatus.pending);
    await repository.upsertLocal(animal);
    // Usa el mismo provider/cola que el alta real y espera el 503 completo.
    await repository.enqueueRemoteUpsert(animal);
    parentStarted = Completer<void>();
    allowParent = Completer<void>();
    offline = false;
    final saved = await sales.saveSale(_sale('dependent-sale', [animal.localId]));
    expect(jsonDecode(saved.pendingAnimalIdsJson), [animal.localId]);
    await sales.dispose();
    BrickLivestockSaleStore.configure(repository);
    sales = BrickLivestockSaleStore.instance;
    await sales.pushPendingSales('establishment-id');
    expect(requests.where((request) => request.url.path == '/api/v1/ventas'), isEmpty);

    // Se espera el retry automatico de la cola instalada, con su backoff real.
    await parentStarted!.future.timeout(const Duration(seconds: 15));
    expect(requests.where((request) => request.url.path == '/api/v1/ventas'), isEmpty);
    allowParent!.complete();
    parentStarted = null;
    allowParent = null;
    final sale = await waitForSale('dependent-sale', BrickLivestockSaleSyncStatus.synchronized);
    expect(jsonDecode(sale.pendingAnimalIdsJson), isEmpty);
    final saleRequests = requests.where((request) => request.url.path == '/api/v1/ventas').toList();
    expect(saleRequests, hasLength(1));
    expect(jsonDecode(saleRequests.single.body), containsPair('id', 'dependent-sale'));
    expect((await animals.getAnimalById(animal.localId))?.syncStatus, BrickAnimalSyncStatus.synchronized);
    expect((await animals.getAnimalById(animal.localId))?.productiveStatus, BrickAnimalProductiveStatus.sold);
    // Un ACK duplicado del alta no debe marcar nuevamente la venta pendiente.
    await repository.enqueueRemoteUpsert(animal);
    expect((await animals.getAnimalById(animal.localId))?.syncStatus, BrickAnimalSyncStatus.synchronized);
    expect(
      (await repository.getLocal<BrickLivestockSaleModel>()).where((sale) => sale.localId == 'dependent-sale'),
      hasLength(1),
    );
  });

  test('la ficha reintenta la venta rechazada con el mismo payload y UUID', () async {
    final animal = _animal('retry-sale-animal');
    await repository.upsertLocal(animal);
    knownAnimals.add(animal.localId);
    rejectSale = true;
    await sales.saveSale(_sale('rejected-sale', [animal.localId]));
    await waitForSale('rejected-sale', BrickLivestockSaleSyncStatus.rejected);
    final before = requests.length;
    final original = requests.last.body;
    rejectSale = false;
    final detailRepository = AnimalDetailRepositoryImpl(
      brickStore: animals,
      saleSyncRecovery: sales,
      categoriaBrickStore: BrickCategoriaStore.instance,
      lotBrickStore: BrickLotStore.instance,
      pesajeBrickStore: BrickPesajeStore.instance,
      remoteDataSource: AnimalDetailRemoteDataSource(tokenProvider: const _TokenProvider()),
    );
    expect(await detailRepository.retrySync(animal.localId), const Result<void>.success(null));
    await waitForSale('rejected-sale', BrickLivestockSaleSyncStatus.synchronized);
    expect(requests.skip(before).map((request) => request.url.path), ['/api/v1/ventas']);
    expect(requests.last.body, original);
    final updated = await animals.getAnimalById(animal.localId);
    expect(updated?.productiveStatus, BrickAnimalProductiveStatus.sold);
    expect(updated?.syncStatus, BrickAnimalSyncStatus.synchronized);
    expect(updated?.syncErrorCode, isNull);
  });

  test('espera todas las altas de la tropa antes de enviar la venta', () async {
    final parents = [
      _animal('parent-a').copyWith(syncStatus: BrickAnimalSyncStatus.pending),
      _animal('parent-b').copyWith(syncStatus: BrickAnimalSyncStatus.pending),
    ];
    offline = true;
    for (final parent in parents) {
      await repository.upsertLocal(parent);
      await repository.enqueueRemoteUpsert(parent);
    }
    await sales.saveSale(_sale('multi-parent-sale', parents.map((parent) => parent.localId).toList()));
    offline = false;
    final countBefore = requests.where((request) => request.url.path == '/api/v1/ventas').length;
    await repository.enqueueRemoteUpsert(parents.first);
    final waiting = await waitForSale('multi-parent-sale', BrickLivestockSaleSyncStatus.pending);
    expect(jsonDecode(waiting.pendingAnimalIdsJson), [parents.last.localId]);
    expect(requests.where((request) => request.url.path == '/api/v1/ventas'), hasLength(countBefore));
    await repository.enqueueRemoteUpsert(parents.last);
    await waitForSale('multi-parent-sale', BrickLivestockSaleSyncStatus.synchronized);
  });

  test('si falla un alta dependiente, recupera primero el alta y luego la misma venta', () async {
    rejectParent = true;
    parentStarted = Completer<void>();
    allowParent = Completer<void>();
    final parent = _animal('rejected-parent').copyWith(syncStatus: BrickAnimalSyncStatus.pending);
    await animals.upsertAnimal(parent);
    await parentStarted!.future;
    await sales.saveSale(_sale('parent-rejected-sale', [parent.localId]));
    allowParent!.complete();
    await waitForSale('parent-rejected-sale', BrickLivestockSaleSyncStatus.rejected);
    parentStarted = null;
    allowParent = null;
    rejectParent = false;
    final before = requests.length;
    expect(await sales.retryRejectedSaleForAnimal(parent.localId), isTrue);
    await waitForSale('parent-rejected-sale', BrickLivestockSaleSyncStatus.synchronized);
    expect(requests.skip(before).map((request) => request.url.path), ['/api/v1/animales', '/api/v1/ventas']);
    expect((await animals.getAnimalById(parent.localId))?.productiveStatus, BrickAnimalProductiveStatus.sold);
  });

  test('un alta rechazada despues de seleccionar aborta la venta sin borrar el rechazo', () async {
    final parent = _animal('rejected-before-sale').copyWith(syncStatus: BrickAnimalSyncStatus.pending);
    final peer = _animal('valid-selected-peer');
    await repository.upsertLocal(parent);
    await repository.upsertLocal(peer);
    final selectionSnapshot = await animals.getAnimalById(parent.localId);
    expect(selectionSnapshot?.syncStatus, BrickAnimalSyncStatus.pending);

    final rejectionApplied = repository.localChanges
        .where((type) => type == BrickAnimalModel)
        .asyncMap((_) => animals.getAnimalById(parent.localId))
        .firstWhere((animal) => animal?.syncStatus == BrickAnimalSyncStatus.rejected)
        .timeout(const Duration(seconds: 2));
    rejectParent = true;
    await repository.enqueueRemoteUpsert(parent);
    final rejected = await rejectionApplied;
    rejectParent = false;
    final requestCount = requests.length;

    await expectLater(
      sales.saveSale(_sale('sale-after-rejection', [peer.localId, parent.localId])),
      throwsA(
        isA<LivestockSaleLocalException>().having(
          (error) => error.code,
          'code',
          LivestockSaleLocalErrorCode.animalSyncRejected,
        ),
      ),
    );

    expect(
      (await repository.getLocal<BrickLivestockSaleModel>()).where((sale) => sale.localId == 'sale-after-rejection'),
      isEmpty,
    );
    expect(requests.skip(requestCount), isEmpty);
    final preserved = await animals.getAnimalById(parent.localId);
    expect(preserved?.productiveStatus, BrickAnimalProductiveStatus.active);
    expect(preserved?.syncStatus, BrickAnimalSyncStatus.rejected);
    expect(preserved?.syncErrorCode, rejected?.syncErrorCode);
    expect(preserved?.updatedAt, rejected?.updatedAt);
    expect((await animals.getAnimalById(peer.localId))?.productiveStatus, BrickAnimalProductiveStatus.active);
    expect((await animals.getAnimalById(peer.localId))?.syncStatus, BrickAnimalSyncStatus.synchronized);
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
    productiveStatus: BrickAnimalProductiveStatus.active,
    syncStatus: BrickAnimalSyncStatus.synchronized,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

BrickLivestockSaleModel _sale(String id, List<String> animalIds, {DateTime? operationDate}) {
  final timestamp = DateTime.utc(2026, 10, 3, 18, 30);
  return BrickLivestockSaleModel(
    localId: id,
    establishmentId: 'establishment-id',
    operationDate: operationDate ?? DateTime(2026, 10, 3),
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
