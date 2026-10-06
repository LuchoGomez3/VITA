import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/livestock_sale_brick_store.dart';
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
        _animal('active', 'activo'),
        _animal('sold', 'vendido'),
        _animal('dead', 'muerto'),
        _animal('removed', 'baja'),
        _animal('unknown', 'desconocido'),
      ]),
      categoryStore: const _FakeCategoryStore(),
      pesajeStore: const _FakeWeighingStore(),
      secureStorage: _FakeSecureStorage(),
      operatingExpenseStore: const _FakeExpenseStore(),
      saleStore: const _FakeSaleStore([]),
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

  test('balance respeta establecimiento y suma ventas pendientes sin duplicar cobros', () async {
    final repository = _financialRepository(
      sales: [
        _sale('sale-a', '1200000.00'),
        _sale('sale-b', '10000.25'),
        _sale('other-sale', '9000000.00', establishmentId: 'other-establishment'),
      ],
      expenses: [
        _expense('508100.00'),
        _expense('50.00', establishmentId: 'other-establishment'),
      ],
    );
    final result = await repository.getDashboard(establishmentIds: {'establishment-id'});
    final dashboard = (result as Success<HomeDashboard>).data;
    expect(dashboard.salesRevenueCents, 121000025);
    expect(dashboard.operatingExpensesCents, 50810000);
    expect(dashboard.operatingBalanceCents, 70190025);

    final combined = await repository.getDashboard();
    expect((combined as Success<HomeDashboard>).data.operatingBalanceCents, 970185025);
  });

  test('sin ventas el balance muestra la pérdida por gastos registrados', () async {
    final repository = _financialRepository(expenses: [_expense('508100.00')]);
    final result = await repository.getDashboard(establishmentIds: {'establishment-id'});
    final dashboard = (result as Success<HomeDashboard>).data;
    expect(dashboard.salesRevenueCents, 0);
    expect(dashboard.operatingBalanceCents, -50810000);
  });
}

BrickAnimalModel _animal(
  String id,
  String status,
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
    status: status,
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
  Future<List<BrickCategoriaModel>> getLocalCategorias([
    String? establishmentId,
  ]) async => const [];

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
  const _FakeExpenseStore([this.expenses = const []]);

  final List<BrickOperatingExpenseModel> expenses;

  @override
  Future<List<BrickOperatingExpenseModel>> getLocalExpenses(
    String? establishmentId,
  ) async =>
      expenses.where((expense) => establishmentId == null || expense.establishmentId == establishmentId).toList();

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

/// Simula la lectura ya filtrada del store, sin acoplar Home a otra feature.
class _FakeSaleStore implements LivestockSaleHistoryBrickStore {
  const _FakeSaleStore(this.sales);

  final List<BrickLivestockSaleModel> sales;

  @override
  Future<List<BrickLivestockSaleModel>> getSales(String? establishmentId) async =>
      sales.where((sale) => establishmentId == null || sale.establishmentId == establishmentId).toList();

  @override
  Future<BrickLivestockSaleModel> collectUnpaidSale(BrickLivestockSaleModel sale) =>
      throw UnsupportedError('Home solamente consulta ventas.');
}

HomeDashboardRepositoryImpl _financialRepository({
  List<BrickLivestockSaleModel> sales = const [],
  List<BrickOperatingExpenseModel> expenses = const [],
}) => HomeDashboardRepositoryImpl(
  animalStore: const _FakeAnimalStore([]),
  categoryStore: const _FakeCategoryStore(),
  pesajeStore: const _FakeWeighingStore(),
  secureStorage: _FakeSecureStorage(),
  operatingExpenseStore: _FakeExpenseStore(expenses),
  saleStore: _FakeSaleStore(sales),
);

BrickLivestockSaleModel _sale(String id, String amount, {String establishmentId = 'establishment-id'}) =>
    BrickLivestockSaleModel(
      localId: id,
      establishmentId: establishmentId,
      operationDate: DateTime.utc(2026, 10, 5),
      buyerType: 'frigorifico',
      buyerName: 'Frigorífico Demo',
      isCompany: true,
      dteNumber: '12345678-9',
      saleType: 'al_bulto',
      totalAmount: amount,
      animalIdsJson: '["animal-id"]',
      paymentCondition: 'pendiente',
      createdAt: DateTime.utc(2026, 10, 5),
      updatedAt: DateTime.utc(2026, 10, 5),
    );

BrickOperatingExpenseModel _expense(String amount, {String establishmentId = 'establishment-id'}) =>
    BrickOperatingExpenseModel(
      localId: 'expense-$establishmentId',
      establishmentId: establishmentId,
      amount: amount,
      type: 'costo_produccion',
      category: 'sanidad',
      supply: 'Vacunas',
      date: DateTime.utc(2026, 10, 5),
      loadedById: 'user-id',
      loadedByName: 'Demo',
      createdAt: DateTime.utc(2026, 10, 5),
      updatedAt: DateTime.utc(2026, 10, 5),
    );
