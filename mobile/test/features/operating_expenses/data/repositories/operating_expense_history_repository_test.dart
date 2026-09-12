import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/datasources/operating_expense_remote_data_source.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/models/operating_expense_remote_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/repositories/operating_expense_repository_impl.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';

void main() {
  group('OperatingExpenseRepositoryImpl history', () {
    test('mes actual filtra y totaliza centavos sin double', () async {
      final store = _ExpenseStore([
        _expense(id: 'august', amount: '100.25', date: DateTime(2026, 8, 20)),
        _expense(id: 'july', amount: '500.00', date: DateTime(2026, 7, 31)),
      ]);
      final repository = _repository(store);

      final result = await repository.getLocalHistory(
        establishmentId: 'establishment-id',
        filters: OperatingExpenseFilters.initial(DateTime(2026, 8, 26)),
      );

      final history = (result as Success<OperatingExpenseHistory>).data;
      expect(history.expenses.map((item) => item.id), ['august']);
      expect(history.totalCents, 10025);
    });

    test('tipo costo y categoria sanidad conservan orden y total', () async {
      final store = _ExpenseStore([
        _expense(id: 'older', amount: '10.00', date: DateTime(2026, 8, 1)),
        _expense(
          id: 'fuel',
          amount: '50.00',
          date: DateTime(2026, 8, 25),
          type: 'gasto_administrativo',
          category: 'combustible',
        ),
        _expense(id: 'newer', amount: '20.50', date: DateTime(2026, 8, 24)),
      ]);

      final result = await _repository(store).getLocalHistory(
        establishmentId: 'establishment-id',
        filters: OperatingExpenseFilters.initial(DateTime(2026, 8, 26)).copyWith(
          type: OperatingExpenseType.productionCost,
          category: 'sanidad',
        ),
      );

      final history = (result as Success<OperatingExpenseHistory>).data;
      expect(history.expenses.map((item) => item.id), ['newer', 'older']);
      expect(history.totalCents, 3050);
    });

    test('combina total remoto con pendiente y no duplica UUID confirmado', () async {
      final store = _ExpenseStore([
        _expense(id: 'confirmed', amount: '100.00', syncStatus: BrickOperatingExpenseSyncStatus.pending),
        _expense(
          id: 'fuel-pending',
          amount: '50.00',
          type: 'gasto_administrativo',
          category: 'combustible',
          syncStatus: BrickOperatingExpenseSyncStatus.pending,
        ),
      ]);
      final remote = _RemoteSource(
        page: OperatingExpenseRemotePage(
          expenses: [
            _remoteExpense(
              id: 'confirmed',
              amount: '100.00',
              updatedAt: DateTime(2026, 8, 27),
            ),
          ],
          totalCents: 10000,
        ),
      );

      final result = await _repository(store, remote: remote).refreshHistory(
        establishmentId: 'establishment-id',
        filters: const OperatingExpenseFilters(period: OperatingExpensePeriod.allHistory),
      );

      final history = (result as Success<OperatingExpenseHistory>).data;
      expect(history.expenses.map((item) => item.id).toSet(), {'confirmed', 'fuel-pending'});
      expect(history.totalCents, 15000);
      expect(history.pendingCount, 1);
      expect(history.totalIncludesPending, isTrue);
    });

    test('reemplaza en el total una version remota anterior por la local pendiente', () async {
      final store = _ExpenseStore([
        _expense(
          id: 'edited-offline',
          amount: '150.00',
          updatedAt: DateTime.utc(2026, 8, 27),
          syncStatus: BrickOperatingExpenseSyncStatus.pending,
        ),
      ]);
      final remote = _RemoteSource(
        page: OperatingExpenseRemotePage(
          expenses: [
            _remoteExpense(
              id: 'edited-offline',
              amount: '100.00',
              updatedAt: DateTime.utc(2026, 8, 26),
            ),
          ],
          totalCents: 10000,
        ),
      );

      final result = await _repository(store, remote: remote).refreshHistory(
        establishmentId: 'establishment-id',
        filters: const OperatingExpenseFilters(period: OperatingExpensePeriod.allHistory),
      );

      final history = (result as Success<OperatingExpenseHistory>).data;
      expect(history.totalCents, 15000);
      expect(history.pendingCount, 1);
      expect(history.expenses.single.amountCents, 15000);
    });

    test('elimina de la vista una copia remota que dejo de coincidir', () async {
      final store = _ExpenseStore([
        _expense(
          id: 'moved',
          amount: '100.00',
          updatedAt: DateTime.utc(2026, 8, 26),
        ),
      ]);
      final remote = _RemoteSource(
        page: OperatingExpenseRemotePage(
          expenses: [
            _remoteExpense(
              id: 'moved',
              amount: '100.00',
              category: 'alimentacion',
              updatedAt: DateTime.utc(2026, 8, 27),
            ),
          ],
          totalCents: 10000,
        ),
      );

      final result = await _repository(store, remote: remote).refreshHistory(
        establishmentId: 'establishment-id',
        filters: const OperatingExpenseFilters(
          period: OperatingExpensePeriod.allHistory,
          category: 'sanidad',
        ),
      );

      final history = (result as Success<OperatingExpenseHistory>).data;
      expect(history.expenses, isEmpty);
      expect(history.totalCents, 0);
    });

    test('reconcilia categorias personalizadas del catalogo', () async {
      final remote = _RemoteSource(
        catalog: const [
          OperatingExpenseRemoteCatalogType(
            type: 'costo_produccion',
            categories: [
              OperatingExpenseRemoteCategory(
                value: 'reparacion_manga',
                label: 'Reparación de manga',
                custom: true,
              ),
            ],
          ),
        ],
      );
      final repository = _repository(_ExpenseStore([]), remote: remote);

      final result = await repository.refreshCategories(establishmentId: 'establishment-id');

      final categories = (result as Success<List<OperatingExpenseCategory>>).data;
      expect(categories.any((item) => item.value == 'reparacion_manga'), isTrue);
    });
  });
}

OperatingExpenseRepositoryImpl _repository(_ExpenseStore store, {_RemoteSource? remote}) =>
    OperatingExpenseRepositoryImpl(
      expenseStore: store,
      categoryStore: _CategoryStore(),
      remoteDataSource: remote ?? _RemoteSource(),
      now: () => DateTime.utc(2026, 8, 26),
    );

BrickOperatingExpenseModel _expense({
  required String id,
  required String amount,
  DateTime? date,
  DateTime? updatedAt,
  String type = 'costo_produccion',
  String category = 'sanidad',
  BrickOperatingExpenseSyncStatus syncStatus = BrickOperatingExpenseSyncStatus.synchronized,
}) => BrickOperatingExpenseModel(
  localId: id,
  establishmentId: 'establishment-id',
  amount: amount,
  type: type,
  category: category,
  supply: id,
  date: date ?? DateTime(2026, 8, 26),
  loadedByName: 'Ana Productora',
  createdAt: DateTime.utc(2026, 8, 26),
  updatedAt: updatedAt ?? DateTime.utc(2026, 8, 26),
  syncStatus: syncStatus,
);

OperatingExpenseRemoteDto _remoteExpense({
  required String id,
  required String amount,
  String category = 'sanidad',
  DateTime? updatedAt,
}) => OperatingExpenseRemoteDto(
  id: id,
  establishmentId: 'establishment-id',
  amount: amount,
  type: 'costo_produccion',
  category: category,
  supply: id,
  date: DateTime(2026, 8, 26),
  createdAt: DateTime.utc(2026, 8, 26),
  updatedAt: updatedAt ?? DateTime.utc(2026, 8, 26),
);

class _ExpenseStore implements OperatingExpenseBrickStore {
  _ExpenseStore(this.expenses);

  final List<BrickOperatingExpenseModel> expenses;

  @override
  Future<List<BrickOperatingExpenseModel>> getLocalExpenses(String? establishmentId) async =>
      BrickOperatingExpenseStore.selectLocalExpenses(expenses, establishmentId: establishmentId);

  @override
  Future<void> reconcileRemoteExpenses(Iterable<BrickOperatingExpenseModel> remote) async {
    for (final item in remote) {
      expenses.removeWhere((local) => local.localId == item.localId && !local.updatedAt.isAfter(item.updatedAt));
      if (!expenses.any((local) => local.localId == item.localId)) expenses.add(item);
    }
  }

  @override
  Future<void> pullRemoteExpenses(String establishmentId) => throw UnimplementedError();

  @override
  Future<BrickOperatingExpenseModel> upsertExpense(BrickOperatingExpenseModel expense) => throw UnimplementedError();
}

class _CategoryStore implements OperatingExpenseCategoryBrickStore {
  final categories = <BrickOperatingExpenseCategoryModel>[];

  @override
  Future<void> cacheRemoteCategories(Iterable<BrickOperatingExpenseCategoryModel> values) async {
    categories.addAll(values);
  }

  @override
  Future<List<BrickOperatingExpenseCategoryModel>> getLocalCategories({
    required String establishmentId,
    required String type,
  }) async => categories.where((item) => item.establishmentId == establishmentId && item.type == type).toList();

  @override
  Future<BrickOperatingExpenseCategoryModel?> getById(String id) async => null;

  @override
  Future<BrickOperatingExpenseCategoryModel> upsertCategory(BrickOperatingExpenseCategoryModel category) =>
      throw UnimplementedError();
}

class _RemoteSource implements OperatingExpenseRemoteDataSource {
  _RemoteSource({
    this.page = const OperatingExpenseRemotePage(expenses: [], totalCents: 0),
    this.catalog = const [],
  });

  final OperatingExpenseRemotePage page;
  final List<OperatingExpenseRemoteCatalogType> catalog;

  @override
  Future<OperatingExpenseRemotePage> getExpenses(String establishmentId, OperatingExpenseFilters filters) async => page;

  @override
  Future<List<OperatingExpenseRemoteCatalogType>> getCatalog(String establishmentId) async => catalog;

  @override
  Future<OperatingExpenseExport> export(String establishmentId, OperatingExpenseFilters filters) async =>
      OperatingExpenseExport(bytes: Uint8List(0), filename: 'egresos.csv', mediaType: 'text/csv');
}
