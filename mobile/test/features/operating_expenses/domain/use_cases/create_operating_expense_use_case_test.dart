import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
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

  setUp(() {
    repository = _FakeRepository();
    useCase = CreateOperatingExpenseUseCase(repository);
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

      expect((result as Failure<OperatingExpense>).error.message, OperatingExpenseValidationMessages.invalidAmount);
      expect(repository.saved, isNull);
    });
  }

  test('rechaza una fecha futura antes de persistir', () async {
    final result = await useCase(
      expense: _expense(amountCents: 4500000, date: today.add(const Duration(days: 1))),
      categories: const [category],
      today: today,
    );

    expect((result as Failure<OperatingExpense>).error.message, OperatingExpenseValidationMessages.futureDate);
    expect(repository.saved, isNull);
  });

  test('rechaza categoria incompatible con el tipo', () async {
    final result = await useCase(
      expense: _expense(amountCents: 100, date: today, type: OperatingExpenseType.administrativeExpense),
      categories: const [category],
      today: today,
    );

    expect(
      (result as Failure<OperatingExpense>).error.message,
      OperatingExpenseValidationMessages.incompatibleCategory,
    );
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
  }) => throw UnimplementedError();
  @override
  Future<Result<List<OperatingExpenseCategory>>> getCategories({
    required String establishmentId,
    required OperatingExpenseType type,
  }) => throw UnimplementedError();
}
