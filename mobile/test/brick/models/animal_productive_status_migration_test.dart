import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/db/schema.g.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('productive status migrations are additive and latest is registered', () {
    final migration = migrations.singleWhere(
      (item) => item.version == 20261014141500,
    );
    final statusDateMigration = migrations.singleWhere(
      (item) => item.version == 20261015133521,
    );

    expect(schema.version, 20261028002455);
    expect(
      migrations.where((item) => item.version == 20261015043521),
      isEmpty,
    );
    expect(
      migration.upStatement,
      contains(
        'ALTER TABLE `BrickAnimalModel` ADD `productive_status` VARCHAR NULL',
      ),
    );
    expect(migration.upStatement, isNot(contains('DROP')));
    expect(
      statusDateMigration.upStatement,
      contains(
        'ALTER TABLE `BrickAnimalModel` ADD `productive_status_changed_at` DATETIME NULL',
      ),
    );
    expect(statusDateMigration.upStatement, isNot(contains('DROP')));
  });

  test('upgrading a legacy table preserves its existing animals', () async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    await database.execute(
      'CREATE TABLE BrickAnimalModel '
      '(_brick_id INTEGER PRIMARY KEY, local_id VARCHAR)',
    );
    await database.insert('BrickAnimalModel', {
      '_brick_id': 1,
      'local_id': 'legacy-animal',
    });
    final migration = migrations.singleWhere(
      (item) => item.version == 20261014141500,
    );
    final statusDateMigration = migrations.singleWhere(
      (item) => item.version == 20261015133521,
    );

    await database.execute(migration.upStatement);
    await database.execute(statusDateMigration.upStatement);

    final rows = await database.query('BrickAnimalModel');
    expect(rows, hasLength(1));
    expect(rows.single['local_id'], 'legacy-animal');
    expect(rows.single['productive_status'], isNull);
    expect(rows.single['productive_status_changed_at'], isNull);
  });
}
