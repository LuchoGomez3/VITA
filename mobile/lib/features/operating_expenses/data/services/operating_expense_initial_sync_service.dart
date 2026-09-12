import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/datasources/operating_expense_remote_data_source.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/mappers/operating_expense_category_brick_mapper.dart';

/// Prepara el catálogo y los egresos de un establecimiento para uso offline.
class OperatingExpenseInitialSyncService {
  /// Crea el coordinador con transporte y stores inyectables.
  OperatingExpenseInitialSyncService({
    required OperatingExpenseRemoteDataSource remoteDataSource,
    required OperatingExpenseCategoryBrickStore categoryStore,
    required OperatingExpenseBrickStore expenseStore,
    DateTime Function()? now,
  }) : _remoteDataSource = remoteDataSource,
       _categoryStore = categoryStore,
       _expenseStore = expenseStore,
       _now = now ?? DateTime.now;

  final OperatingExpenseRemoteDataSource _remoteDataSource;
  final OperatingExpenseCategoryBrickStore _categoryStore;
  final OperatingExpenseBrickStore _expenseStore;
  final DateTime Function() _now;

  /// Descarga una sola vez el catálogo, lo reconcilia y luego trae los egresos.
  Future<void> call(String establishmentId) async {
    final groups = await _remoteDataSource.getCatalog(establishmentId);
    await _categoryStore.cacheRemoteCategories(
      OperatingExpenseCategoryBrickMapper.fromRemoteCatalog(
        groups: groups,
        establishmentId: establishmentId,
        cachedAt: _now().toUtc(),
      ),
    );
    await _expenseStore.pullRemoteExpenses(establishmentId);
  }
}
