import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/repositories/operating_expense_repository.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';

void main() {
  const category = OperatingExpenseCategory(
    value: 'sanidad',
    label: 'Sanidad',
    type: OperatingExpenseType.productionCost,
  );
  final today = DateTime(2026, 8, 12);
  late _FakeRepository repository;
  late CreateOperatingExpenseUseCase useCase;
  late OperatingExpenseCatalogUseCase catalogUseCase;

  setUp(() {
    repository = _FakeRepository();
    useCase = CreateOperatingExpenseUseCase(repository);
    catalogUseCase = OperatingExpenseCatalogUseCase(repository);
  });

  test('guarda localmente un egreso valido de vacunas por 150000', () async {
    final expense = _expense(amountCents: 15000000, date: today);

    final result = await useCase(expense: expense, categories: const [category], today: today);

    expect(result, isA<Success<OperatingExpense>>());
    expect(repository.saved, same(expense));
  });

  for (final cents in [0, -100]) {
    test('rechaza monto no positivo en centavos: $cents', () async {
      final result = await useCase(
        expense: _expense(amountCents: cents, date: today),
        categories: const [category],
        today: today,
      );

      final error = (result as Failure<OperatingExpense>).error;
      expect(error.code, DomainErrorCode.validation);
      expect(error.reason, OperatingExpenseValidationError.invalidAmount);
      expect(repository.saved, isNull);
    });
  }

  test('rechaza una fecha futura antes de persistir', () async {
    final result = await useCase(
      expense: _expense(amountCents: 4500000, date: today.add(const Duration(days: 1))),
      categories: const [category],
      today: today,
    );

    expect(
      (result as Failure<OperatingExpense>).error.reason,
      OperatingExpenseValidationError.futureDate,
    );
    expect(repository.saved, isNull);
  });

  test('rechaza categoria incompatible con el tipo', () async {
    final result = await useCase(
      expense: _expense(amountCents: 100, date: today, type: OperatingExpenseType.administrativeExpense),
      categories: const [category],
      today: today,
    );

    expect(
      (result as Failure<OperatingExpense>).error.reason,
      OperatingExpenseValidationError.incompatibleCategory,
    );
  });

  test('rechaza un nombre de categoria vacio antes de acceder al repositorio', () async {
    final result = await catalogUseCase.createCategory(
      'establishment-id',
      OperatingExpenseType.productionCost,
      '   ',
    );

    expect(
      (result as Failure<OperatingExpenseCategory>).error.reason,
      OperatingExpenseValidationError.requiredCategoryName,
    );
    expect(repository.createdCategoryName, isNull);
  });
}

OperatingExpense _expense({
  required int amountCents,
  required DateTime date,
  OperatingExpenseType type = OperatingExpenseType.productionCost,
}) => OperatingExpense(
  id: 'expense-id',
  establishmentId: 'establishment-id',
  amountCents: amountCents,
  type: type,
  category: 'sanidad',
  supply: 'Vacunas reproductivas',
  date: date,
  createdAt: date,
  updatedAt: date,
  syncStatus: OperatingExpenseSyncStatus.pending,
);

class _FakeRepository implements OperatingExpenseRepository {
  OperatingExpense? saved;
  String? createdCategoryName;

  @override
  Future<Result<OperatingExpense>> createExpense(OperatingExpense expense) async {
    saved = expense;
    return Result.success(expense);
  }

  @override
  Future<Result<OperatingExpenseCategory>> createCategory({
    required String establishmentId,
    required OperatingExpenseType type,
    required String name,
  }) async {
    createdCategoryName = name;
    return Result.success(
      OperatingExpenseCategory(
        value: name,
        label: name,
        type: type,
      ),
    );
  }

  @override
  Future<Result<List<OperatingExpenseCategory>>> getCategories({
    required String establishmentId,
    required OperatingExpenseType type,
  }) => throw UnimplementedError();

  @override
  Future<Result<OperatingExpenseExport>> exportHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) => throw UnimplementedError();

  @override
  Future<Result<OperatingExpenseHistory>> getLocalHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) => throw UnimplementedError();

  @override
  Future<Result<List<OperatingExpenseCategory>>> refreshCategories({required String establishmentId}) =>
      throw UnimplementedError();

  @override
  Future<Result<OperatingExpenseHistory>> refreshHistory({
    required String establishmentId,
    required OperatingExpenseFilters filters,
  }) => throw UnimplementedError();
}
