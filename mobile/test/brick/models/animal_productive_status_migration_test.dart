import 'dart:io';

import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/db/brick_migrations.dart';
import 'package:frontend_mayoral/brick/db/schema.g.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('productive status migrations remain registered and additive', () {
    final migration = migrations.singleWhere(
      (item) => item.version == 20261014141500,
    );
    final statusDateMigration = migrations.singleWhere(
      (item) => item.version == 20261015133521,
    );

    // El esquema registra la migración más nueva, sea cual sea: fijar un número
    // rompía el test con cada migración posterior.
    final latest = migrations.map((item) => item.version).reduce((a, b) => a > b ? a : b);
    expect(schema.version, latest);
    expect(schema.version, greaterThanOrEqualTo(statusDateMigration.version));
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

  for (final preMergeHealth in [false, true]) {
    test('upgrades SQLite from ${preMergeHealth ? 'the original health branch' : 'develop'}', () async {
      sqfliteFfiInit();
      final directory = await Directory.systemTemp.createTemp('vita_brick_upgrade_');
      final path = directory.uri.resolve('brick.sqlite').toFilePath();
      final database = await databaseFactoryFfi.openDatabase(path);
      addTearDown(() async {
        await database.close();
        await databaseFactoryFfi.deleteDatabase(path);
        await directory.delete();
      });
      final provider = SqliteProvider(
        path,
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteModelDictionary,
      );
      final manager = MigrationManager(appBrickMigrations);
      final health = appBrickMigrations.singleWhere(
        (migration) => migration.upStatement.contains('BrickHealthEventModel'),
      );
      expect(health.version, greaterThan(20261122000200));

      final sourceVersion = preMergeHealth ? 20261015133521 : 20261122000200;
      await provider.migrate(
        manager.migrationsSince(-1).takeWhile((migration) => migration.version <= sourceVersion).toList(),
      );
      await database.insert('BrickAnimalModel', {'local_id': 'legacy-animal'});
      if (preMergeHealth) {
        await provider.migrate([_OriginalHealthMigration(health.up)]);
        await database.insert('BrickHealthOperationModel', {'local_id': 'pending-operation'});
      }

      await upgradePreMergeHealthDatabase(provider);
      await provider.migrate(manager.migrationsSince(await provider.lastMigrationVersion()));

      final animal = (await database.query('BrickAnimalModel')).single;
      expect(animal['local_id'], 'legacy-animal');
      expect(animal, contains('local_registration_author_id'));
      expect(await database.query('BrickHealthEventModel'), isEmpty);
      final operations = await database.query('BrickHealthOperationModel');
      expect(operations.map((row) => row['local_id']), preMergeHealth ? ['pending-operation'] : isEmpty);
      expect(await database.query('BrickFoodModel'), isEmpty);
      expect(await database.query('BrickLivestockSaleModel'), isEmpty);
      expect(await provider.lastMigrationVersion(), schema.version);
    });
  }
}

class _OriginalHealthMigration extends Migration {
  const _OriginalHealthMigration(List<MigrationCommand> up) : super(version: 20261120223303, up: up, down: const []);
}
