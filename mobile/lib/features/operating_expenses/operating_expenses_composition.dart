import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/datasources/operating_expense_remote_data_source.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/repositories/operating_expense_repository_impl.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/services/operating_expense_api_service.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_history_cubit.dart';

/// Construye el cubit con la infraestructura offline-first real.
OperatingExpenseCubit createOperatingExpenseCubit({
  required String establishmentId,
  required String userId,
  required String userName,
}) {
  final repository = _createRepository();
  return OperatingExpenseCubit(
    establishmentId: establishmentId,
    userId: userId,
    userName: userName,
    createExpense: CreateOperatingExpenseUseCase(repository),
    catalog: OperatingExpenseCatalogUseCase(repository),
  );
}

/// Construye el historial con cache Brick y consultas autenticadas.
OperatingExpenseHistoryCubit createOperatingExpenseHistoryCubit({required String establishmentId}) {
  final repository = _createRepository();
  return OperatingExpenseHistoryCubit(
    establishmentId: establishmentId,
    getHistory: GetOperatingExpenseHistoryUseCase(repository),
    localCatalog: OperatingExpenseCatalogUseCase(repository),
    refreshCatalog: RefreshOperatingExpenseCatalogUseCase(repository),
    exportExpenses: ExportOperatingExpensesUseCase(repository),
  );
}

OperatingExpenseRepositoryImpl _createRepository() => OperatingExpenseRepositoryImpl(
  expenseStore: BrickOperatingExpenseStore.instance,
  categoryStore: BrickOperatingExpenseCategoryStore.instance,
  remoteDataSource: OperatingExpenseRemoteDataSource(
    service: OperatingExpenseApiService(
      baseUrl: AppConfig.current.backendBaseUrl,
      tokenProvider: SessionBackendAccessTokenProvider.instance,
    ),
  ),
);
