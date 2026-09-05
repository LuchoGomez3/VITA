import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';

void main() {
  test('getById selection uses the latest updatedAt version', () {
    final older = _category(
      updatedAt: DateTime.utc(2026, 8, 26),
      status: BrickOperatingExpenseCategorySyncStatus.pending,
    );
    final newer = _category(
      updatedAt: DateTime.utc(2026, 8, 27),
      status: BrickOperatingExpenseCategorySyncStatus.synchronized,
    );

    final selected = BrickOperatingExpenseCategoryStore.selectLatestById(
      [newer, older],
      'category-id',
    );

    expect(
      selected?.syncStatus,
      BrickOperatingExpenseCategorySyncStatus.synchronized,
    );
  });
}

BrickOperatingExpenseCategoryModel _category({
  required DateTime updatedAt,
  required BrickOperatingExpenseCategorySyncStatus status,
}) => BrickOperatingExpenseCategoryModel(
  localId: 'category-id',
  establishmentId: 'establishment-id',
  type: 'costo_produccion',
  name: 'Reparacion',
  value: 'reparacion',
  createdAt: DateTime.utc(2026, 8, 26),
  updatedAt: updatedAt,
  syncStatus: status,
);
