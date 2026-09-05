import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/operating_expense_catalog_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/data/models/establishment_remote_summary.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/initial_data_sync_repository_impl.dart';

void main() {
  test('refreshes offline data on every login', () async {
    final animalStore = _FakeAnimalStore();
    final categoryStore = _FakeCategoryStore();
    final weighingStore = _FakeWeighingStore();
    final expenseStore = _FakeOperatingExpenseStore();
    final expenseCategoryStore = _FakeOperatingExpenseCategoryStore();
    final expenseCatalogSource = _FakeOperatingExpenseCatalogRemoteDataSource();
    final repository = InitialDataSyncRepositoryImpl(
      secureStorage: _MemoryStorage(),
      establishmentRemoteDataSource: _FakeEstablishmentRemoteDataSource(),
      animalStore: animalStore,
      categoryStore: categoryStore,
      weighingStore: weighingStore,
      operatingExpenseStore: expenseStore,
      operatingExpenseCategoryStore: expenseCategoryStore,
      operatingExpenseCatalogRemoteDataSource: expenseCatalogSource,
    );

    await repository.sync();
    await repository.sync();

    expect(animalStore.pulls, ['establishment-1', 'establishment-1']);
    expect(categoryStore.pulls, ['establishment-1', 'establishment-1']);
    expect(weighingStore.pulls, ['establishment-1', 'establishment-1']);
    expect(expenseStore.pulls, ['establishment-1', 'establishment-1']);
    expect(
      expenseCatalogSource.pulls,
      ['establishment-1', 'establishment-1'],
    );
  });

  test('persists the establishment role in the offline catalog', () async {
    final storage = _MemoryStorage();
    final repository = InitialDataSyncRepositoryImpl(
      secureStorage: storage,
      establishmentRemoteDataSource: _FakeEstablishmentRemoteDataSource(),
      animalStore: _FakeAnimalStore(),
      categoryStore: _FakeCategoryStore(),
      weighingStore: _FakeWeighingStore(),
      operatingExpenseStore: _FakeOperatingExpenseStore(),
      operatingExpenseCategoryStore: _FakeOperatingExpenseCategoryStore(),
      operatingExpenseCatalogRemoteDataSource: _FakeOperatingExpenseCatalogRemoteDataSource(),
    );

    await repository.sync();

    final encoded = await storage.read(SecureStorageKeys.establishmentCatalog);
    final catalog = jsonDecode(encoded!) as List<dynamic>;
    expect(catalog.single, containsPair('role', 'owner'));
  });

  test('does not hydrate finances for a role without access', () async {
    final expenseStore = _FakeOperatingExpenseStore();
    final expenseCatalogSource = _FakeOperatingExpenseCatalogRemoteDataSource();
    final repository = InitialDataSyncRepositoryImpl(
      secureStorage: _MemoryStorage(),
      establishmentRemoteDataSource: _FakeEstablishmentRemoteDataSource(
        role: UserRole.employee,
      ),
      animalStore: _FakeAnimalStore(),
      categoryStore: _FakeCategoryStore(),
      weighingStore: _FakeWeighingStore(),
      operatingExpenseStore: expenseStore,
      operatingExpenseCategoryStore: _FakeOperatingExpenseCategoryStore(),
      operatingExpenseCatalogRemoteDataSource: expenseCatalogSource,
    );

    await repository.sync();

    expect(expenseStore.pulls, isEmpty);
    expect(expenseCatalogSource.pulls, isEmpty);
  });
}

class _FakeOperatingExpenseStore implements OperatingExpenseBrickStore {
  final List<String> pulls = [];

  @override
  Future<void> pullRemoteExpenses(String establishmentId) async {
    pulls.add(establishmentId);
  }

  @override
  Future<List<BrickOperatingExpenseModel>> getLocalExpenses(
    String? establishmentId,
  ) async => [];

  @override
  Future<void> reconcileRemoteExpenses(
    Iterable<BrickOperatingExpenseModel> expenses,
  ) async {}

  @override
  Future<BrickOperatingExpenseModel> upsertExpense(
    BrickOperatingExpenseModel expense,
  ) async => expense;
}

class _FakeOperatingExpenseCategoryStore implements OperatingExpenseCategoryBrickStore {
  @override
  Future<void> cacheRemoteCategories(
    Iterable<BrickOperatingExpenseCategoryModel> categories,
  ) async {}

  @override
  Future<BrickOperatingExpenseCategoryModel?> getById(String id) async => null;

  @override
  Future<List<BrickOperatingExpenseCategoryModel>> getLocalCategories({
    required String establishmentId,
    required String type,
  }) async => [];

  @override
  Future<BrickOperatingExpenseCategoryModel> upsertCategory(
    BrickOperatingExpenseCategoryModel category,
  ) async => category;
}

class _FakeOperatingExpenseCatalogRemoteDataSource implements OperatingExpenseCatalogRemoteDataSource {
  final List<String> pulls = [];

  @override
  Future<List<BrickOperatingExpenseCategoryModel>> fetchCustomCategories(
    String establishmentId,
  ) async {
    pulls.add(establishmentId);
    return [];
  }
}

class _FakeEstablishmentRemoteDataSource implements EstablishmentRemoteDataSource {
  _FakeEstablishmentRemoteDataSource({this.role = UserRole.owner});

  final UserRole role;

  @override
  Future<List<EstablishmentRemoteSummary>> fetchEstablishments() async => [
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
  final List<String> pulls = [];

  @override
  Future<void> pullRemoteCategorias(String establishmentId) async {
    pulls.add(establishmentId);
  }

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias(
    String establishmentId,
  ) async => [];

  @override
  Future<BrickCategoriaModel> upsertCategoria(
    BrickCategoriaModel categoria,
  ) async => categoria;
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
