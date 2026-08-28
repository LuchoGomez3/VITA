import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/repositories/operating_expense_repository.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_history_cubit.dart';

void main() {
  late _HistoryRepository repository;
  late OperatingExpenseHistoryCubit cubit;

  setUp(() {
    repository = _HistoryRepository();
    cubit = OperatingExpenseHistoryCubit(
      establishmentId: 'establishment-id',
      getHistory: GetOperatingExpenseHistoryUseCase(repository),
      localCatalog: OperatingExpenseCatalogUseCase(repository),
      refreshCatalog: RefreshOperatingExpenseCatalogUseCase(repository),
      exportExpenses: ExportOperatingExpensesUseCase(repository),
      now: () => DateTime(2026, 8, 26),
    );
  });

  tearDown(() => cubit.close());

  test('abre con mes actual y total consolidado correspondiente', () async {
    await cubit.load();

    final history = (cubit.state.history as Data<OperatingExpenseHistory>).data;
    expect(cubit.state.filters.period, OperatingExpensePeriod.currentMonth);
    expect(history.expenses.map((item) => item.id), ['health']);
    expect(history.totalCents, 10000);
  });

  test('tipo costo y Sanidad filtran de inmediato y conservan orden', () async {
    await cubit.load();
    await cubit.selectType(OperatingExpenseType.productionCost);
    await cubit.selectCategory('sanidad');

    final history = (cubit.state.history as Data<OperatingExpenseHistory>).data;
    expect(history.expenses.map((item) => item.id), ['health']);
    expect(history.totalCents, 10000);
    expect(repository.lastFilters?.category, 'sanidad');
  });

  test('al cambiar tipo limpia una categoria incompatible', () async {
    await cubit.load();
    await cubit.selectType(OperatingExpenseType.productionCost);
    await cubit.selectCategory('sanidad');
    await cubit.selectType(OperatingExpenseType.administrativeExpense);

    expect(cubit.state.filters.category, isNull);
  });

  test('exporta con el establecimiento y los filtros inmutables vigentes', () async {
    await cubit.selectType(OperatingExpenseType.productionCost);
    await cubit.selectCategory('sanidad');

    await cubit.exportCsv();

    expect(repository.exportedEstablishmentId, 'establishment-id');
    expect(repository.exportedFilters?.type, OperatingExpenseType.productionCost);
    expect(repository.exportedFilters?.category, 'sanidad');
    expect(cubit.state.export, isA<Data<OperatingExpenseExport>>());
  });
}

class _HistoryRepository implements OperatingExpenseRepository {
  OperatingExpenseFilters? lastFilters;
  OperatingExpenseFilters? exportedFilters;
  String? exportedEstablishmentId;

  final _expenses = [
    OperatingExpense(
      id: 'fuel',
      establishmentId: 'establishment-id',
      amountCents: 5000,
      type: OperatingExpenseType.administrativeExpense,
      category: 'combustible',
      supply: 'Gasoil',
      date: DateTime(2026, 7, 20),
      createdAt: DateTime.utc(2026, 7, 20),
      updatedAt: DateTime.utc(2026, 7, 20),
      syncStatus: OperatingExpenseSyncStatus.synchronized,
    ),
    OperatingExpense(
      id: 'health',
      establishmentId: 'establishment-id',
      amountCents: 10000,
      type: OperatingExpenseType.productionCost,
      category: 'sanidad',
      supply: 'Vacunas',
      date: DateTime(2026, 8, 25),
      createdAt: DateTime.utc(2026, 8, 25),
      updatedAt: DateTime.utc(2026, 8, 25),
      syncStatus: OperatingExpenseSyncStatus.synchronized,
    ),
  ];

  @override
  Future<Result<OperatingExpenseHistory>> getLocalHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) async => Result.success(_history(filters, cached: true));

  @override
  Future<Result<OperatingExpenseHistory>> refreshHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) async {
    lastFilters = filters;
    return Result.success(_history(filters, cached: false));
  }

  OperatingExpenseHistory _history(OperatingExpenseFilters filters, {required bool cached}) {
    final visible = _expenses.where((item) {
      return (filters.from == null || !item.date.isBefore(filters.from!)) &&
          (filters.to == null || !item.date.isAfter(filters.to!)) &&
          (filters.type == null || item.type == filters.type) &&
          (filters.category == null || item.category == filters.category);
    }).toList()..sort((left, right) => right.date.compareTo(left.date));
    return OperatingExpenseHistory(
      expenses: visible,
      totalCents: visible.fold(0, (sum, item) => sum + item.amountCents),
      cachedWithoutConnection: cached,
    );
  }

  @override
  Future<Result<List<OperatingExpenseCategory>>> getCategories({
    required String establishmentId,
    required OperatingExpenseType type,
  }) async => Result.success(
    type == OperatingExpenseType.productionCost
        ? const [
            OperatingExpenseCategory(value: 'sanidad', label: 'Sanidad', type: OperatingExpenseType.productionCost),
          ]
        : const [
            OperatingExpenseCategory(
              value: 'combustible',
              label: 'Combustible',
              type: OperatingExpenseType.administrativeExpense,
            ),
          ],
  );

  @override
  Future<Result<List<OperatingExpenseCategory>>> refreshCategories({required String establishmentId}) async =>
      const Result.success([
        OperatingExpenseCategory(value: 'sanidad', label: 'Sanidad', type: OperatingExpenseType.productionCost),
        OperatingExpenseCategory(
          value: 'combustible',
          label: 'Combustible',
          type: OperatingExpenseType.administrativeExpense,
        ),
      ]);

  @override
  Future<Result<OperatingExpenseExport>> exportHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) async {
    exportedEstablishmentId = establishmentId;
    exportedFilters = filters;
    return Result.success(
      OperatingExpenseExport(bytes: Uint8List.fromList([1]), filename: 'egresos_operativos.csv', mediaType: 'text/csv'),
    );
  }

  @override
  Future<Result<OperatingExpenseCategory>> createCategory({
    required String establishmentId,
    required OperatingExpenseType type,
    required String name,
  }) => throw UnimplementedError();

  @override
  Future<Result<OperatingExpense>> createExpense(OperatingExpense expense) => throw UnimplementedError();
}
