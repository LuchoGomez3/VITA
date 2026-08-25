import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/repositories/operating_expense_repository.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

void main() {
  test('muestra la validacion cuando se intenta agregar una categoria vacia', () async {
    final repository = _FakeRepository();
    final cubit = OperatingExpenseCubit(
      establishmentId: 'establishment-id',
      userId: 'user-id',
      userName: 'Usuario',
      createExpense: CreateOperatingExpenseUseCase(repository),
      catalog: OperatingExpenseCatalogUseCase(repository),
      createId: () => 'expense-id',
    );
    addTearDown(cubit.close);

    await cubit.addCategory('   ');

    expect(cubit.state.errorMessage, OperatingExpenseStrings.requiredCategoryName);
    expect(repository.createCategoryCalls, 0);
  });
}

class _FakeRepository implements OperatingExpenseRepository {
  int createCategoryCalls = 0;

  @override
  Future<Result<OperatingExpenseCategory>> createCategory({
    required String establishmentId,
    required OperatingExpenseType type,
    required String name,
  }) async {
    createCategoryCalls++;
    throw UnimplementedError();
  }

  @override
  Future<Result<OperatingExpense>> createExpense(OperatingExpense expense) => throw UnimplementedError();

  @override
  Future<Result<List<OperatingExpenseCategory>>> getCategories({
    required String establishmentId,
    required OperatingExpenseType type,
  }) => throw UnimplementedError();
}
