import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/feeding_record.model.dart';
import 'package:frontend_mayoral/brick/models/food.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/models/lot_forage_period.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/feeding_record_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/food_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_forage_period_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/data/establishment_remote_summary.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/initial_data_sync_repository_impl.dart';

void main() {
  test('refreshes offline data on every login', () async {
    final animalStore = _FakeAnimalStore();
    final categoryStore = _FakeCategoryStore();
    final lotStore = _FakeLotStore();
    final foragePeriodStore = _FakeForagePeriodStore();
    final foodStore = _FakeFoodStore();
    final feedingRecordStore = _FakeFeedingRecordStore();
    final weighingStore = _FakeWeighingStore();
    final movementStore = _FakeMovementStore();
    final financialSync = _FakeOperatingExpenseSync();
    final saleSync = _FakeOperatingExpenseSync();
    final repository = InitialDataSyncRepositoryImpl(
      secureStorage: _MemoryStorage(),
      establishmentRemoteDataSource: _FakeEstablishmentRemoteDataSource(),
      animalStore: animalStore,
      categoryStore: categoryStore,
      lotStore: lotStore,
      foragePeriodStore: foragePeriodStore,
      foodStore: foodStore,
      feedingRecordStore: feedingRecordStore,
      weighingStore: weighingStore,
      movementStore: movementStore,
      syncOperatingExpenseData: financialSync.call,
      syncLivestockSaleData: saleSync.call,
    );

    await repository.sync();
    await repository.sync();

    expect(animalStore.pulls, [
      'establishment-1',
      'establishment-1',
      'establishment-1',
      'establishment-1',
    ]);
    expect(categoryStore.pullCount, 2);
    expect(lotStore.pulls, ['establishment-1', 'establishment-1']);
    expect(lotStore.pushes, ['establishment-1', 'establishment-1']);
    expect(foragePeriodStore.pushes, ['establishment-1', 'establishment-1']);
    expect(foragePeriodStore.pulls, ['establishment-1', 'establishment-1']);
    expect(foodStore.calls, [
      'push:establishment-1',
      'pull:establishment-1',
      'push:establishment-1',
      'pull:establishment-1',
    ]);
    expect(feedingRecordStore.calls, [
      'push:establishment-1',
      'pull:establishment-1',
      'push:establishment-1',
      'pull:establishment-1',
    ]);
    expect(weighingStore.pulls, ['establishment-1', 'establishment-1']);
    expect(movementStore.pulls, ['establishment-1', 'establishment-1']);
    expect(movementStore.pushes, ['establishment-1', 'establishment-1']);
    expect(financialSync.pulls, ['establishment-1', 'establishment-1']);
    expect(saleSync.pulls, ['establishment-1', 'establishment-1']);
  });

  test('persists the establishment role in the offline catalog', () async {
    final storage = _MemoryStorage();
    final repository = InitialDataSyncRepositoryImpl(
      secureStorage: storage,
      establishmentRemoteDataSource: _FakeEstablishmentRemoteDataSource(),
      animalStore: _FakeAnimalStore(),
      categoryStore: _FakeCategoryStore(),
      lotStore: _FakeLotStore(),
      foragePeriodStore: _FakeForagePeriodStore(),
      foodStore: _FakeFoodStore(),
      feedingRecordStore: _FakeFeedingRecordStore(),
      weighingStore: _FakeWeighingStore(),
      movementStore: _FakeMovementStore(),
      syncOperatingExpenseData: _FakeOperatingExpenseSync().call,
      syncLivestockSaleData: _FakeOperatingExpenseSync().call,
    );

    await repository.sync();

    final encoded = await storage.read(SecureStorageKeys.establishmentCatalog);
    final catalog = jsonDecode(encoded!) as List<dynamic>;
    expect(catalog.single, containsPair('role', 'owner'));
  });

  test('does not hydrate finances for a role without access', () async {
    final financialSync = _FakeOperatingExpenseSync();
    final saleSync = _FakeOperatingExpenseSync();
    final repository = InitialDataSyncRepositoryImpl(
      secureStorage: _MemoryStorage(),
      establishmentRemoteDataSource: _FakeEstablishmentRemoteDataSource(
        role: UserRole.employee,
      ),
      animalStore: _FakeAnimalStore(),
      categoryStore: _FakeCategoryStore(),
      lotStore: _FakeLotStore(),
      foragePeriodStore: _FakeForagePeriodStore(),
      foodStore: _FakeFoodStore(),
      feedingRecordStore: _FakeFeedingRecordStore(),
      weighingStore: _FakeWeighingStore(),
      movementStore: _FakeMovementStore(),
      syncOperatingExpenseData: financialSync.call,
      syncLivestockSaleData: saleSync.call,
    );

    await repository.sync();

    expect(financialSync.pulls, isEmpty);
    expect(saleSync.pulls, isEmpty);
  });
  test('una consulta de catálogo de otra sesión no persiste ni inicia descargas', () async {
    final pending = Completer<List<EstablishmentRemoteSummary>>();
    final remote = _FakeEstablishmentRemoteDataSource(pending: pending.future);
    var identity = 1;
    final storage = _MemoryStorage();
    final categories = _FakeCategoryStore();
    final repository = InitialDataSyncRepositoryImpl(
      secureStorage: storage,
      establishmentRemoteDataSource: remote,
      animalStore: _FakeAnimalStore(),
      categoryStore: categories,
      lotStore: _FakeLotStore(),
      foragePeriodStore: _FakeForagePeriodStore(),
      foodStore: _FakeFoodStore(),
      feedingRecordStore: _FakeFeedingRecordStore(),
      weighingStore: _FakeWeighingStore(),
      movementStore: _FakeMovementStore(),
      syncOperatingExpenseData: _FakeOperatingExpenseSync().call,
      syncLivestockSaleData: (_) async {},
      sessionIdentity: () => identity,
    );
    final syncing = repository.sync();
    identity++;
    await storage.write(key: SecureStorageKeys.establishmentCatalog, value: 'next-session-catalog');
    pending.complete(await _FakeEstablishmentRemoteDataSource().fetchEstablishments());
    expect(await syncing, isA<Failure<PostAuthenticationSummary>>());
    expect(await storage.read(SecureStorageKeys.establishmentCatalog), 'next-session-catalog');
    expect(categories.pullCount, 0);
  });
}

class _FakeOperatingExpenseSync {
  final List<String> pulls = [];

  Future<void> call(String establishmentId) async {
    pulls.add(establishmentId);
  }
}

class _FakeEstablishmentRemoteDataSource implements EstablishmentRemoteDataSource {
  _FakeEstablishmentRemoteDataSource({this.role = UserRole.owner, this.pending});

  final Future<List<EstablishmentRemoteSummary>>? pending;

  final UserRole role;

  @override
  Future<List<EstablishmentRemoteSummary>> fetchEstablishments() async =>
      pending ??
      [
        EstablishmentRemoteSummary(
          id: 'establishment-1',
          ownerId: 'owner-1',
          name: 'Establecimiento',
          role: role,
          createdAt: _date,
          updatedAt: _date,
        ),
      ];
}

final _date = DateTime.utc(2026);

class _MemoryStorage implements SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }
}

class _FakeAnimalStore implements AnimalBrickStore {
  final List<String> pulls = [];

  @override
  Future<void> pullRemoteAnimals(String establishmentId) async {
    pulls.add(establishmentId);
  }

  @override
  Future<void> retryRejectedAnimal(String animalId) async {}

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) async => animal;

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async => null;

  @override
  Future<BrickAnimalModel?> getAnimalByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async => null;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => [];

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async => animal;
}

class _FakeCategoryStore implements CategoriaBrickStore {
  int pullCount = 0;

  @override
  Future<void> pullRemoteCategorias() async => pullCount += 1;

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias() async => [];
}

class _FakeLotStore implements LotBrickStore {
  final List<String> pulls = [];
  final List<String> pushes = [];

  @override
  Future<void> setLocalForageResource(String lotId, String? forageResourceCode) async {}

  @override
  Future<BrickLotModel?> getLocalLot(String lotId) async => null;

  @override
  Future<List<BrickLotModel>> getLocalLots(String establishmentId, {bool includeDeleted = false}) async => [];

  @override
  Future<void> pullRemoteLots(String establishmentId) async {
    pulls.add(establishmentId);
  }

  @override
  Future<void> pushPendingLots(String establishmentId) async {
    pushes.add(establishmentId);
  }

  @override
  Future<BrickLotModel> upsertLocalLot(BrickLotModel lot) async => lot;
}

class _FakeForagePeriodStore implements LotForagePeriodBrickStore {
  final List<String> pulls = [];
  final List<String> pushes = [];

  @override
  Future<List<BrickLotForagePeriodModel>> getLocalPeriods(String establishmentId, {String? lotId}) async => const [];

  @override
  Future<void> pullRemotePeriods(String establishmentId) async {
    pulls.add(establishmentId);
  }

  @override
  Future<void> pushPendingPeriods(String establishmentId) async {
    pushes.add(establishmentId);
  }

  @override
  Future<BrickLotForagePeriodModel> save(BrickLotForagePeriodModel period) async => period;
}

class _FakeFoodStore implements FoodBrickStore {
  final List<String> calls = [];

  @override
  Future<List<BrickFoodModel>> getLocalFoods(String establishmentId) async => const [];

  @override
  Future<void> pullRemoteFoods(String establishmentId) async => calls.add('pull:$establishmentId');

  @override
  Future<void> pushPendingFoods(String establishmentId) async => calls.add('push:$establishmentId');
}

class _FakeFeedingRecordStore implements FeedingRecordBrickStore {
  final List<String> calls = [];

  @override
  Future<List<BrickFeedingRecordModel>> getLocalRecords(String establishmentId) async => const [];

  @override
  Future<void> pullRemoteRecords(String establishmentId) async => calls.add('pull:$establishmentId');

  @override
  Future<void> pushPendingRecords(String establishmentId) async => calls.add('push:$establishmentId');

  @override
  Future<BrickFeedingRecordModel> save(BrickFeedingRecordModel record, {BrickFoodModel? newFood}) async => record;
}

class _FakeMovementStore implements AnimalLotMovementBrickStore {
  @override
  Future<List<BrickAnimalLotMovementModel>> getLocalMovements(String establishmentId) async => const [];

  final List<String> pulls = [];
  final List<String> pushes = [];

  @override
  Future<void> pullRemoteMovements(String establishmentId) async {
    pulls.add(establishmentId);
  }

  @override
  Future<void> pushPendingMovements(String establishmentId) async {
    pushes.add(establishmentId);
  }

  @override
  Future<BrickAnimalLotMovementModel> save(
    BrickAnimalLotMovementModel movement,
  ) async => movement;

  @override
  Future<BrickAnimalLotMovementModel> saveWithAnimals({
    required List<BrickAnimalModel> animals,
    required BrickAnimalLotMovementModel movement,
  }) async => movement;
}

class _FakeWeighingStore implements PesajeBrickStore {
  final List<String> pulls = [];

  @override
  Future<void> pullRemotePesajes(
    String establishmentId, {
    String? animalId,
  }) async {
    pulls.add(establishmentId);
  }

  @override
  Future<List<BrickPesajeModel>> getLocalPesajes() async => [];

  @override
  Future<List<BrickPesajeModel>> getLocalPesajesByAnimal(
    String animalId,
  ) async => [];

  @override
  Future<List<BrickPesajeModel>> loadPesajesByAnimal(
    String establishmentId,
    String animalId,
  ) async => [];

  @override
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje) async => pesaje;
}
