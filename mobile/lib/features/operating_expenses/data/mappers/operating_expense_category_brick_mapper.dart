import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/models/operating_expense_remote_page.dart';

/// Convierte categorías remotas en modelos de caché Brick.
class OperatingExpenseCategoryBrickMapper {
  const OperatingExpenseCategoryBrickMapper._();

  /// Convierte las categorías personalizadas del catálogo remoto.
  static Iterable<BrickOperatingExpenseCategoryModel> fromRemoteCatalog({
    required Iterable<OperatingExpenseRemoteCatalogType> groups,
    required String establishmentId,
    required DateTime cachedAt,
  }) => groups.expand(
    (group) => group.categories
        .where((category) => category.custom)
        .map(
          (category) => BrickOperatingExpenseCategoryModel(
            localId: category.id ?? 'catalog:${group.type}:${category.value}:$establishmentId',
            establishmentId: establishmentId,
            type: group.type,
            name: category.label,
            value: category.value,
            createdAt: cachedAt,
            updatedAt: cachedAt,
            syncStatus: BrickOperatingExpenseCategorySyncStatus.synchronized,
          ),
        ),
  );
}
