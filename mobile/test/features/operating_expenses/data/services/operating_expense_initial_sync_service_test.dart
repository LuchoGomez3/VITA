import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/datasources/operating_expense_remote_data_source.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/models/operating_expense_remote_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/services/operating_expense_initial_sync_service.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';

void main() {
  test('cachea el catálogo remoto antes de descargar los egresos', () async {
    final calls = <String>[];
    final categoryStore = _CategoryStore(calls);
    final service = OperatingExpenseInitialSyncService(
      remoteDataSource: _RemoteDataSource(calls),
      categoryStore: categoryStore,
      expenseStore: _ExpenseStore(calls),
      now: () => DateTime.utc(2026, 9, 5),
    );

    await service('establishment-id');

    expect(calls, ['catalog', 'cache', 'expenses']);
    expect(categoryStore.categories.single.value, 'reparacion');
    expect(
      categoryStore.categories.single.syncStatus,
      BrickOperatingExpenseCategorySyncStatus.synchronized,
    );
  });
}

class _RemoteDataSource implements OperatingExpenseRemoteDataSource {
  _RemoteDataSource(this.calls);

  final List<String> calls;

  @override
  Future<List<OperatingExpenseRemoteCatalogType>> getCatalog(
    String establishmentId,
  ) async {
    calls.add('catalog');
    return const [
      OperatingExpenseRemoteCatalogType(
        type: 'costo_produccion',
        categories: [
          OperatingExpenseRemoteCategory(
            value: 'reparacion',
            label: 'Reparación',
            custom: true,
          ),
        ],
      ),
    ];
  }

  @override
  Future<OperatingExpenseRemotePage> getExpenses(
    String establishmentId,
    OperatingExpenseFilters filters,
  ) => throw UnimplementedError();

  @override
  Future<OperatingExpenseExport> export(
    String establishmentId,
    OperatingExpenseFilters filters,
  ) async => OperatingExpenseExport(
    bytes: Uint8List(0),
    filename: 'egresos.csv',
    mediaType: 'text/csv',
  );
}

class _CategoryStore implements OperatingExpenseCategoryBrickStore {
  _CategoryStore(this.calls);

  final List<String> calls;
  final categories = <BrickOperatingExpenseCategoryModel>[];

  @override
  Future<void> cacheRemoteCategories(
    Iterable<BrickOperatingExpenseCategoryModel> values,
  ) async {
    calls.add('cache');
    categories.addAll(values);
  }

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

class _ExpenseStore implements OperatingExpenseBrickStore {
  _ExpenseStore(this.calls);

  final List<String> calls;

  @override
  Future<void> pullRemoteExpenses(String establishmentId) async {
    calls.add('expenses');
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
