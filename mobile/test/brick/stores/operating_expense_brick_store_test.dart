import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';

void main() {
  group('BrickOperatingExpenseStore.selectLocalExpenses', () {
    test('incluye todos los establecimientos cuando el filtro es nulo', () {
      final expenses = [
        _expense(localId: 'expense-a', establishmentId: 'establishment-a'),
        _expense(localId: 'expense-b', establishmentId: 'establishment-b'),
      ];

      final selected = BrickOperatingExpenseStore.selectLocalExpenses(
        expenses,
        establishmentId: null,
      );

      expect(selected.map((expense) => expense.localId), containsAll(['expense-a', 'expense-b']));
    });
  });

  group('BrickOperatingExpenseStore.rejectExpenseForCategory', () {
    test('rechaza el egreso pending que depende de la categoria rechazada', () {
      final expense = _expense();

      final rejected = BrickOperatingExpenseStore.rejectExpenseForCategory(
        expense: expense,
        categoryId: 'category-id',
        errorCode: 'duplicate_category',
      );

      expect(rejected.syncStatus, BrickOperatingExpenseSyncStatus.rejected);
      expect(rejected.syncErrorCode, 'duplicate_category');
      expect(rejected.primaryKey, expense.primaryKey);
    });

    test('no modifica un egreso que depende de otra categoria', () {
      final expense = _expense();

      final unchanged = BrickOperatingExpenseStore.rejectExpenseForCategory(
        expense: expense,
        categoryId: 'other-category-id',
        errorCode: 'duplicate_category',
      );

      expect(unchanged, same(expense));
    });
  });
}

BrickOperatingExpenseModel _expense({
  String localId = 'expense-id',
  String establishmentId = 'establishment-id',
}) => BrickOperatingExpenseModel(
  localId: localId,
  establishmentId: establishmentId,
  amount: '150000.00',
  type: 'costo_produccion',
  category: 'vacunas',
  supply: 'Vacunas reproductivas',
  date: DateTime(2026, 8, 21),
  createdAt: DateTime(2026, 8, 21),
  updatedAt: DateTime(2026, 8, 21),
  customCategoryId: 'category-id',
)..primaryKey = 7;
