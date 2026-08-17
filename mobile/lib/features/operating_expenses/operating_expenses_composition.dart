import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/repositories/operating_expense_repository_impl.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_cubit.dart';

/// Construye el cubit con la infraestructura offline-first real.
OperatingExpenseCubit createOperatingExpenseCubit({
  required String establishmentId,
  required String userId,
  required String userName,
}) {
  final repository = OperatingExpenseRepositoryImpl(
    expenseStore: BrickOperatingExpenseStore.instance,
    categoryStore: BrickOperatingExpenseCategoryStore.instance,
  );
  return OperatingExpenseCubit(
    establishmentId: establishmentId,
    userId: userId,
    userName: userName,
    createExpense: CreateOperatingExpenseUseCase(repository),
    catalog: OperatingExpenseCatalogUseCase(repository),
  );
}
