import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/db/schema.g.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('productive status migrations remain registered and additive', () {
    final migration = migrations.singleWhere(
      (item) => item.version == 20261015043521,
    );
    final statusDateMigration = migrations.singleWhere(
      (item) => item.version == 20261015133521,
    );

    expect(schema.version, greaterThanOrEqualTo(statusDateMigration.version));
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

  test('upgrading through the health migration preserves existing animals', () async {
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
      (item) => item.version == 20261015043521,
    );
    final statusDateMigration = migrations.singleWhere(
      (item) => item.version == 20261015133521,
    );
    final healthMigration = migrations.singleWhere(
      (item) => item.version == 20261120223303,
    );

    await database.execute(migration.upStatement);
    await database.execute(statusDateMigration.upStatement);
    for (final command in healthMigration.up) {
      if (command.statement case final statement?) await database.execute(statement);
    }

    final rows = await database.query('BrickAnimalModel');
    expect(rows, hasLength(1));
    expect(rows.single['local_id'], 'legacy-animal');
    expect(rows.single['productive_status'], isNull);
    expect(rows.single['productive_status_changed_at'], isNull);
    expect(rows.single['local_registration_author_id'], isNull);
    expect(await database.query('BrickHealthEventModel'), isEmpty);
    expect(await database.query('BrickHealthOperationModel'), isEmpty);
  });
}
