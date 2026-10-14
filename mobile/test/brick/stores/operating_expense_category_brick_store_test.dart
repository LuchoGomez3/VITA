import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

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

  test('deduplica identidad natural y conserva el UUID creado offline', () {
    final local = _category(
      id: 'real-uuid',
      updatedAt: DateTime.utc(2026, 9, 4),
      status: BrickOperatingExpenseCategorySyncStatus.pending,
    );
    final downloaded = _category(
      id: 'catalog:costo_produccion:reparacion:establishment-id',
      updatedAt: DateTime.utc(2026, 9, 5),
      status: BrickOperatingExpenseCategorySyncStatus.synchronized,
    );

    final selected = BrickOperatingExpenseCategoryStore.selectLocalCategories(
      [downloaded, local],
      establishmentId: 'establishment-id',
      type: 'costo_produccion',
    );

    expect(selected, hasLength(1));
    expect(selected.single.localId, 'real-uuid');
  });

  test('acepta como confirmada una categoría cuyo valor ya existe', () {
    const result = BackendSyncResult(
      resourcePath: '/api/v1/egresos_operativos/categorias',
      localId: 'category-id',
      synchronized: false,
      errorCode: 'categoria_egreso_duplicada',
    );

    expect(BrickOperatingExpenseCategoryStore.isConfirmed(result), isTrue);
  });
}

BrickOperatingExpenseCategoryModel _category({
  required DateTime updatedAt,
  required BrickOperatingExpenseCategorySyncStatus status,
  String id = 'category-id',
}) => BrickOperatingExpenseCategoryModel(
  localId: id,
  establishmentId: 'establishment-id',
  type: 'costo_produccion',
  name: 'Reparacion',
  value: 'reparacion',
  createdAt: DateTime.utc(2026, 8, 26),
  updatedAt: updatedAt,
  syncStatus: status,
);
