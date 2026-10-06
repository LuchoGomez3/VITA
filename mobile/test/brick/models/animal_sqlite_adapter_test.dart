import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';

void main() {
  test('SQLite persists productive status as stable text', () async {
    final provider = _FakeSqliteProvider();
    final adapter = BrickAnimalModelAdapter();
    final row = await adapter.toSqlite(
      _animal('vendido'),
      provider: provider,
    );

    final restored = await adapter.fromSqlite(
      {...row, '_brick_id': 1},
      provider: provider,
    );

    expect(row['status'], 'vendido');
    expect(restored.status, 'vendido');
  });

  test('SQLite reads pre-migration rows as active', () async {
    final provider = _FakeSqliteProvider();
    final adapter = BrickAnimalModelAdapter();
    final row =
        await adapter.toSqlite(
            _animal('activo'),
            provider: provider,
          )
          ..remove('status');

    final restored = await adapter.fromSqlite(
      {...row, '_brick_id': 2},
      provider: provider,
    );

    expect(restored.status, 'activo');
  });

  test('copyWith preserves or explicitly changes productive status', () {
    final sold = _animal('vendido');

    expect(sold.copyWith().status, 'vendido');
    expect(
      sold
          .copyWith(
            status: 'activo',
          )
          .status,
      'activo',
    );
  });
}

BrickAnimalModel _animal(String status) {
  final timestamp = DateTime.utc(2026, 9, 29);
  return BrickAnimalModel(
    localId: 'animal-id',
    rfidTagNumber: '982000412991416',
    visualTag: '003 1295',
    sex: BrickAnimalSex.female,
    breed: 'Angus',
    birthDate: DateTime.utc(2025, 3, 14),
    categoryId: 'category-id',
    lotId: 'lot-id',
    establishmentId: 'establishment-id',
    initialWeight: 32.5,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: timestamp,
    status: status,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _FakeSqliteProvider implements SqliteProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
