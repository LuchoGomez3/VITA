import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';

void main() {
  test('SQLite conserva UUID, auditoria y estado pendiente al rehidratar', () async {
    final provider = _FakeSqliteProvider();
    final adapter = BrickOperatingExpenseModelAdapter();
    final timestamp = DateTime.utc(2026, 8, 26, 12);
    final expense = BrickOperatingExpenseModel(
      localId: 'c72d3845-cab3-4a3c-9474-8f609922ae44',
      establishmentId: 'establishment-id',
      amount: '1000.25',
      type: 'gasto_administrativo',
      category: 'combustible',
      supply: 'Gasoil',
      date: DateTime(2026, 8, 26),
      loadedById: 'user-id',
      loadedByName: 'Ana Productora',
      createdAt: timestamp,
      updatedAt: timestamp,
      syncStatus: BrickOperatingExpenseSyncStatus.pending,
    );

    final row = await adapter.toSqlite(expense, provider: provider);
    final restored = await adapter.fromSqlite({...row, '_brick_id': 7}, provider: provider);

    expect(restored.localId, expense.localId);
    expect(restored.syncStatus, BrickOperatingExpenseSyncStatus.pending);
    expect(restored.loadedByName, 'Ana Productora');
    expect(restored.amount, '1000.25');
  });
}

class _FakeSqliteProvider implements SqliteProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
