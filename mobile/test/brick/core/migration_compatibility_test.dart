import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/core/migration_compatibility.dart';
import 'package:frontend_mayoral/brick/db/schema.g.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  for (final removedColumns in [false, true]) {
    test('migra categorías con columnas retiradas: $removedColumns', () async {
      final provider = _TestSqliteProvider(
        inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteModelDictionary,
      );
      addTearDown(provider.close);
      // Reproduce ambas historias: la rama original conservaba las columnas;
      // la otra rama las retiró en septiembre y las restauró en octubre.
      final previous = migrations
          .where(
            (migration) =>
                migration.version < 20261005193219 &&
                (removedColumns || ![20260910133325, 20260917120957].contains(migration.version)),
          )
          .toList();
      await provider.migrate(previous);
      await provider.rawInsert(
        'INSERT INTO BrickCategoriaModel (local_id, name) VALUES (?, ?)',
        ['category-id', 'Novillito'],
      );
      final compatible = await resolveCompatibleMigrations(provider, migrations);
      await provider.migrate(compatible.where((migration) => migration.version == 20261005193219).toList());

      final columns = await provider.rawQuery('PRAGMA table_info("BrickCategoriaModel")');
      expect(
        columns.map((column) => column['name']),
        containsAll(['establishment_id', 'sync_status', 'sync_error_code']),
      );
      expect((await provider.rawQuery('SELECT * FROM BrickCategoriaModel')).single['name'], 'Novillito');
      expect(await provider.lastMigrationVersion(), 20261005193219);
    });
  }

  test('una instalación nueva aplica toda la historia de migraciones', () async {
    final provider = _TestSqliteProvider(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
      modelDictionary: sqliteModelDictionary,
    );
    addTearDown(provider.close);
    await provider.migrate((await resolveCompatibleMigrations(provider, migrations)).toList());
    expect(await provider.lastMigrationVersion(), 20261005193219);
  });
}

/// Expone el cierre de la conexión en memoria para aislar los escenarios.
class _TestSqliteProvider extends SqliteProvider {
  _TestSqliteProvider(super.dbName, {required super.databaseFactory, required super.modelDictionary});

  Future<void> close() async => (await getDb()).close();
}
