import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/db/brick_migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('la migracion de ventas permanece registrada en el esquema', () {
    final migration = appBrickMigrations.singleWhere(
      (item) => item.version == 20261122000100,
    );

    expect(
      migration.upStatement,
      allOf(
        contains('CREATE TABLE IF NOT EXISTS `BrickLivestockSaleModel`'),
        contains('`price_per_kg` VARCHAR NULL'),
        contains('`initial_payment_json` VARCHAR NULL'),
      ),
    );
  });

  test('la migracion crea la tabla local con los campos economicos', () async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    final migration = appBrickMigrations.singleWhere(
      (item) => item.version == 20261122000100,
    );

    for (final statement in migration.upStatement.split(';')) {
      final sql = statement.trim();
      if (sql.isNotEmpty) {
        await database.execute(sql);
      }
    }

    final columns = await database.rawQuery(
      'PRAGMA table_info(BrickLivestockSaleModel)',
    );
    final names = columns.map((column) => column['name']).toSet();
    expect(
      names,
      containsAll(<String>[
        'local_id',
        'animal_ids_json',
        'total_weight_kg',
        'price_per_kg',
        'total_amount',
        'initial_payment_json',
        'sync_status',
      ]),
    );

    // Reaplicar la migracion simula un dispositivo que ya tenia la tabla por
    // la rama original de ventas. La fila debe sobrevivir sin columnas dobles.
    await database.insert('BrickLivestockSaleModel', {
      'local_id': 'venta-existente',
    });
    for (final statement in migration.upStatement.split(';')) {
      final sql = statement.trim();
      if (sql.isNotEmpty) {
        await database.execute(sql);
      }
    }
    final preservedSales = await database.query(
      'BrickLivestockSaleModel',
      where: 'local_id = ?',
      whereArgs: ['venta-existente'],
    );
    expect(preservedSales, hasLength(1));

    final dependenciesMigration = appBrickMigrations.singleWhere(
      (item) => item.upStatement.contains('pending_animal_ids_json'),
    );
    for (final statement in dependenciesMigration.upStatement.split(';')) {
      if (statement.trim().isNotEmpty) await database.execute(statement);
    }
    final legacySale = (await database.query('BrickLivestockSaleModel')).single;
    expect(legacySale['local_id'], 'venta-existente');
    expect(legacySale['pending_animal_ids_json'], isNull);
  });

  test('conserva ventas al incorporar observaciones desde develop', () async {
    const observationVersion = 20261123235738;
    const saleHistoryVersion = 20261124061506;
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(database.close);
    final provider = SqliteProvider(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
      modelDictionary: sqliteModelDictionary,
    );
    final manager = MigrationManager(appBrickMigrations);
    await provider.migrate([
      for (final migration in manager.migrationsSince(-1))
        if (migration.version <= saleHistoryVersion && migration.version != observationVersion) migration,
    ]);
    await database.insert('BrickLivestockSaleModel', {
      'local_id': 'venta-existente',
      'collected_amount': '1200.00',
    });

    await prepareAppBrickMigrations(provider);
    await database.insert('BrickAnimalObservationModel', {
      'local_id': 'observacion-existente',
    });
    await prepareAppBrickMigrations(provider);

    final sale = (await database.query('BrickLivestockSaleModel')).single;
    expect(sale['local_id'], 'venta-existente');
    expect(sale['collected_amount'], '1200.00');
    final observation = (await database.query('BrickAnimalObservationModel')).single;
    expect(observation['local_id'], 'observacion-existente');
    expect(await provider.lastMigrationVersion(), saleHistoryVersion);
  });
}
