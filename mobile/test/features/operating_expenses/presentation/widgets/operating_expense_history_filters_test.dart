import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/repositories/operating_expense_repository.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_history_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/pages/operating_expense_history_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_history_filters.dart';

void main() {
  testWidgets('mantiene el selector fijo y expande los filtros sin overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: OperatingExpenseHistoryPage(
          establishmentName: 'Establecimiento Norte',
          createCubit: () => _createCubit(_FilterRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final movementSelector = find.byType(SegmentedButton<String>);
    final scrollView = find.byType(CustomScrollView);

    expect(scrollView, findsOneWidget);
    expect(
      find.ancestor(of: movementSelector, matching: scrollView),
      findsNothing,
    );
    expect(find.text(OperatingExpenseStrings.dateRange), findsNothing);

    await tester.tap(find.text(OperatingExpenseStrings.filters));
    await tester.pumpAndSettle();

    final selectorTopBeforeScroll = tester.getTopLeft(movementSelector).dy;
    final summaryTopBeforeScroll = tester
        .getTopLeft(
          find.text('Establecimiento Norte'),
        )
        .dy;

    await tester.drag(scrollView, const Offset(0, -160));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(movementSelector).dy,
      lessThan(selectorTopBeforeScroll),
    );
    expect(
      tester.getTopLeft(find.text('Establecimiento Norte')).dy,
      lessThan(summaryTopBeforeScroll),
    );
    expect(find.byKey(const ValueKey('compact-history-summary')), findsOneWidget);
    expect(find.byKey(const ValueKey('compact-expense-type')), findsOneWidget);
    await tester.drag(scrollView, const Offset(0, 160));
    await tester.pumpAndSettle();

    await tester.tap(find.text(OperatingExpenseStrings.filters));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OperatingExpenseStrings.filters));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(movementSelector, findsOneWidget);
  });

  testWidgets('muestra fechas, categoria y chips de tipo dentro de Filtros', (tester) async {
    final repository = _FilterRepository();
    final cubit = _createCubit(repository);
    addTearDown(cubit.close);
    final state = cubit.state.copyWith(
      categories: const [
        OperatingExpenseCategory(
          value: 'sanidad',
          label: 'Sanidad',
          type: OperatingExpenseType.productionCost,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: SingleChildScrollView(
              child: OperatingExpenseHistoryFilters(state: state),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text(OperatingExpenseStrings.filters));
    await tester.pumpAndSettle();

    expect(find.text(OperatingExpenseStrings.filters), findsOneWidget);
    expect(find.text(OperatingExpenseStrings.dateFrom), findsOneWidget);
    expect(find.text(OperatingExpenseStrings.dateTo), findsOneWidget);
    expect(find.text(OperatingExpenseStrings.category), findsOneWidget);
    expect(find.text(OperatingExpenseStrings.administrativeType), findsOneWidget);
    expect(find.text(OperatingExpenseStrings.productiveType), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(OperatingExpenseStrings.type)).dx,
      tester.getTopLeft(find.text(OperatingExpenseStrings.dateRange)).dx,
    );

    await tester.tap(find.text(OperatingExpenseStrings.productiveType));
    await tester.pumpAndSettle();

    expect(cubit.state.filters.type, OperatingExpenseType.productionCost);
  });
}

OperatingExpenseHistoryCubit _createCubit(
  OperatingExpenseRepository repository,
) {
  return OperatingExpenseHistoryCubit(
    establishmentId: 'establishment-id',
    getHistory: GetOperatingExpenseHistoryUseCase(repository),
    localCatalog: OperatingExpenseCatalogUseCase(repository),
    refreshCatalog: RefreshOperatingExpenseCatalogUseCase(repository),
    exportExpenses: ExportOperatingExpensesUseCase(repository),
    now: () => DateTime(2026, 8, 26),
  );
}

class _FilterRepository implements OperatingExpenseRepository {
  @override
  Future<Result<OperatingExpenseHistory>> getLocalHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) async => const Result.success(
    OperatingExpenseHistory(
      expenses: [],
      totalCents: 0,
      cachedWithoutConnection: false,
    ),
  );

  @override
  Future<Result<OperatingExpenseHistory>> refreshHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) async => const Result.success(
    OperatingExpenseHistory(
      expenses: [],
      totalCents: 0,
      cachedWithoutConnection: false,
    ),
  );

  @override
  Future<Result<List<OperatingExpenseCategory>>> getCategories({
    required String establishmentId,
    required OperatingExpenseType type,
  }) async => const Result.success([]);

  @override
  Future<Result<List<OperatingExpenseCategory>>> refreshCategories({
    required String establishmentId,
  }) async => const Result.success([]);

  @override
  Future<Result<OperatingExpenseExport>> exportHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) async => Result.success(
    OperatingExpenseExport(
      bytes: Uint8List(0),
      filename: 'expenses.csv',
      mediaType: 'text/csv',
    ),
  );

  @override
  Future<Result<OperatingExpenseCategory>> createCategory({
    required String establishmentId,
    required OperatingExpenseType type,
    required String name,
  }) => throw UnimplementedError();

  @override
  Future<Result<OperatingExpense>> createExpense(OperatingExpense expense) => throw UnimplementedError();
}
