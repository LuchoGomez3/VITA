import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/home/data/repositories/home_dashboard_repository_impl.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';

void main() {
  test('stock metrics include only active animals', () async {
    final repository = HomeDashboardRepositoryImpl(
      animalStore: _FakeAnimalStore([
        _animal('active', BrickAnimalProductiveStatus.active),
        _animal('sold', BrickAnimalProductiveStatus.sold),
        _animal('dead', BrickAnimalProductiveStatus.dead),
        _animal('removed', BrickAnimalProductiveStatus.removed),
        _animal('unknown', BrickAnimalProductiveStatus.unknown),
      ]),
      categoryStore: const _FakeCategoryStore(),
      pesajeStore: const _FakeWeighingStore(),
      secureStorage: _FakeSecureStorage(),
      operatingExpenseStore: const _FakeExpenseStore(),
      now: () => DateTime.utc(2026, 9, 29),
    );

    final result = await repository.getDashboard(
      establishmentIds: {'establishment-id'},
    );

    expect(result, isA<Success<HomeDashboard>>());
    final dashboard = (result as Success<HomeDashboard>).data;
    expect(dashboard.activeAnimals, 1);
    expect(dashboard.categories.single.animals, 1);
    expect(dashboard.lots.single.animals, 1);
  });
}

BrickAnimalModel _animal(
  String id,
  BrickAnimalProductiveStatus status,
) {
  final timestamp = DateTime.utc(2026, 8);
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: '982000000000001',
    visualTag: id,
    sex: BrickAnimalSex.female,
    breed: 'Angus',
    birthDate: DateTime.utc(2025),
    categoryId: 'category-id',
    categoryName: 'Vaca',
    lotId: 'lot-id',
    lotName: 'Lote norte',
    establishmentId: 'establishment-id',
    initialWeight: 300,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: timestamp,
    productiveStatus: status,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _FakeAnimalStore implements AnimalBrickStore {
  const _FakeAnimalStore(this.animals);

  final List<BrickAnimalModel> animals;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => animals;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCategoryStore implements CategoriaBrickStore {
  const _FakeCategoryStore();

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias(
    String establishmentId,
  ) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWeighingStore implements PesajeBrickStore {
  const _FakeWeighingStore();

  @override
  Future<List<BrickPesajeModel>> getLocalPesajes() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeExpenseStore implements OperatingExpenseBrickStore {
  const _FakeExpenseStore();

  @override
  Future<List<BrickOperatingExpenseModel>> getLocalExpenses(
    String? establishmentId,
  ) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSecureStorage implements SecureStorageService {
  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write({required String key, required String value}) async {}
}
