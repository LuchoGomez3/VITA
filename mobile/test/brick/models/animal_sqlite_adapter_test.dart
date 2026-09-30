import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';

void main() {
  test('SQLite persists productive status as stable text', () async {
    final provider = _FakeSqliteProvider();
    final adapter = BrickAnimalModelAdapter();
    final row = await adapter.toSqlite(
      _animal(BrickAnimalProductiveStatus.sold),
      provider: provider,
    );

    final restored = await adapter.fromSqlite(
      {...row, '_brick_id': 1},
      provider: provider,
    );

    expect(row['productive_status'], 'sold');
    expect(restored.productiveStatus, BrickAnimalProductiveStatus.sold);
  });

  test('SQLite reads pre-migration rows as active', () async {
    final provider = _FakeSqliteProvider();
    final adapter = BrickAnimalModelAdapter();
    final row =
        await adapter.toSqlite(
            _animal(BrickAnimalProductiveStatus.active),
            provider: provider,
          )
          ..remove('productive_status');

    final restored = await adapter.fromSqlite(
      {...row, '_brick_id': 2},
      provider: provider,
    );

    expect(restored.productiveStatus, BrickAnimalProductiveStatus.active);
  });

  test('copyWith preserves or explicitly changes productive status', () {
    final sold = _animal(BrickAnimalProductiveStatus.sold);

    expect(sold.copyWith().productiveStatus, BrickAnimalProductiveStatus.sold);
    expect(
      sold
          .copyWith(
            productiveStatus: BrickAnimalProductiveStatus.active,
          )
          .productiveStatus,
      BrickAnimalProductiveStatus.active,
    );
  });
}

BrickAnimalModel _animal(BrickAnimalProductiveStatus status) {
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
    productiveStatus: status,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _FakeSqliteProvider implements SqliteProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
