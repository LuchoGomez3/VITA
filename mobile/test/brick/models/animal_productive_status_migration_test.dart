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

      final prepared = MigrationManager(await prepareAppBrickMigrations(provider));
      await provider.migrate(prepared.migrationsSince(await provider.lastMigrationVersion()));

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

  for (final (version, legacyVersion, table, column, value) in [
    (20261122000200, 20261108032415, 'BrickLivestockSaleModel', 'pending_animal_ids_json', '["pending-animal"]'),
    (20261123003833, 20261005112458, 'BrickCategoriaModel', 'allowed_sex', 'hembra'),
    (20261123003833, null, 'BrickCategoriaModel', 'allowed_sex', 'hembra'),
  ]) {
    test('conserva $column al migrar $version desde ${legacyVersion ?? 'un arranque interrumpido'}', () async {
      sqfliteFfiInit();
      final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(database.close);
      final provider = SqliteProvider(
        inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteModelDictionary,
      );
      final manager = MigrationManager(appBrickMigrations);
      final previousMigrations = manager
          .migrationsSince(-1)
          .where(
            (migration) => migration.version < (legacyVersion ?? version),
          );
      await provider.migrate(previousMigrations.toList());

      // Recrea las columnas de las ramas originales o un ALTER ya confirmado
      // por SQLite cuyo número de versión Brick aún no alcanzó a guardar.
      if (table == 'BrickLivestockSaleModel') {
        final sale = appBrickMigrations.singleWhere((migration) => migration.version == 20261122000100);
        await database.execute(sale.upStatement);
      }
      await database.execute('ALTER TABLE $table ADD $column VARCHAR');
      if (legacyVersion != null) {
        await database.insert('MigrationVersions', {'version': legacyVersion});
      }
      await database.insert(table, {'local_id': 'existing-row', column: value});

      final prepared = MigrationManager(await prepareAppBrickMigrations(provider));
      await provider.migrate(prepared.migrationsSince(await provider.lastMigrationVersion()));

      final row = (await database.query(table)).single;
      expect(row['local_id'], 'existing-row');
      expect(row[column], value);
      expect(await provider.lastMigrationVersion(), schema.version);
    });
  }
}

class _OriginalHealthMigration extends Migration {
  const _OriginalHealthMigration(List<MigrationCommand> up) : super(version: 20261120223303, up: up, down: const []);
}
