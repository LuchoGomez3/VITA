import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart';
import 'package:frontend_mayoral/brick/db/schema.g.dart' as generated;
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:sqflite/sqflite.dart';

const _livestockSaleMigrationVersion = 20261122000100;
const _livestockSaleDependenciesVersion = 20261122000200;
const _preMergeHealthVersion = 20261120223303;
const _lastSharedVersion = 20261015133521;
const _healthMigrationVersion = 20261122234613;
const _categoryAllowedSexVersion = 20261123003833;

/// Migraciones ejecutadas por la aplicacion, con compatibilidad entre ramas.
///
/// El esquema generado conserva comandos que Brick puede interpretar durante
/// codegen. En runtime se reemplaza solamente la creacion de ventas por una
/// sentencia idempotente, porque algunos dispositivos ya tienen esa tabla por
/// la rama original de la feature.
Set<Migration> get appBrickMigrations => generated.migrations
    .map(
      (migration) => migration.version == _livestockSaleMigrationVersion
          ? const _LivestockSaleCompatibilityMigration()
          : migration,
    )
    .toSet();

/// Ajusta las migraciones pendientes al esquema físico antes de abrir Brick.
///
/// SQLite puede tener una columna agregada desde otra rama o haber guardado el
/// cambio antes de que Brick registre la versión. Se omite el `ALTER TABLE`
/// correspondiente y Brick registra su versión en el orden habitual.
Future<Set<Migration>> prepareAppBrickMigrations(SqliteProvider sqliteProvider) async {
  final lastVersion = await sqliteProvider.lastMigrationVersion();
  return sqliteProvider.transaction((transaction) async {
    final migrations = <Migration>{
      for (final migration in appBrickMigrations)
        if (migration.version > lastVersion) await _skipExistingColumn(transaction, migration) else migration,
    };
    if (lastVersion == _preMergeHealthVersion) {
      await _upgradePreMergeHealthDatabase(transaction, migrations);
    }
    return migrations;
  });
}

/// Completa los campos agregados después de los primeros lotes offline.
Future<void> repairLegacyBrickData(SqliteProvider sqliteProvider) async {
  await sqliteProvider.transaction((transaction) async {
    final pending = BrickLotSyncStatus.pending.index;
    final rejected = BrickLotSyncStatus.rejected.index;
    // La superficie real no se puede deducir del dibujo. Se conserva el lote,
    // marcado para corregirlo antes de que la cola lo envíe al backend.
    await transaction.rawUpdate(
      '''
UPDATE BrickLotModel
SET geometry_mode = COALESCE(geometry_mode, 'local_schematic'),
    surface_tenths = COALESCE(surface_tenths, 0),
    has_water = COALESCE(has_water, 0),
    status_code = COALESCE(status_code, 'activo'),
    sync_status = CASE
      WHEN surface_tenths IS NULL AND COALESCE(sync_status, ?) = ? THEN ?
      ELSE COALESCE(sync_status, ?)
    END,
    sync_error_code = CASE
      WHEN surface_tenths IS NULL AND COALESCE(sync_status, ?) = ?
      THEN COALESCE(sync_error_code, 'superficie_lote_faltante')
      ELSE sync_error_code
    END
WHERE geometry_mode IS NULL OR surface_tenths IS NULL OR has_water IS NULL
   OR status_code IS NULL OR sync_status IS NULL
''',
      [pending, pending, rejected, pending, pending, pending],
    );
  });
}

/// Omite solo los cambios aditivos conocidos que ya están en la base.
Future<Migration> _skipExistingColumn(Transaction transaction, Migration migration) async {
  if (migration.version != _livestockSaleDependenciesVersion && migration.version != _categoryAllowedSexVersion) {
    return migration;
  }
  if (migration.up case [final InsertColumn column]) {
    final existingColumns = await transaction.rawQuery('PRAGMA table_info("${column.onTable}")');
    if (existingColumns.any((existing) => existing['name'] == column.name)) {
      return _AlreadyAppliedMigration(migration);
    }
  }
  return migration;
}

/// Integra las migraciones omitidas por una instalación anterior de Sanidad.
Future<void> _upgradePreMergeHealthDatabase(Transaction transaction, Set<Migration> preparedMigrations) async {
  final migrations = MigrationManager(preparedMigrations).migrationsSince(_lastSharedVersion);
  for (final migration in migrations.takeWhile((migration) => migration.version <= _healthMigrationVersion)) {
    if (migration.version != _healthMigrationVersion) {
      for (final command in migration.up) {
        if (command.statement case final statement?) await transaction.execute(statement);
      }
    }
    // Sanidad ya existe. SQLite confirma los cambios faltantes y sus versiones
    // en la misma transacción para poder reintentar el arranque.
    await transaction.insert('MigrationVersions', {'version': migration.version});
  }
}

/// Conserva la versión y su reversión cuando la columna ya fue agregada.
class _AlreadyAppliedMigration extends Migration {
  _AlreadyAppliedMigration(Migration migration) : super(version: migration.version, up: const [], down: migration.down);
}

class _LivestockSaleCompatibilityMigration extends Migration {
  const _LivestockSaleCompatibilityMigration()
    : super(
        version: _livestockSaleMigrationVersion,
        up: const [_CreateLivestockSaleTableIfMissing()],
        down: const [DropTable('BrickLivestockSaleModel')],
      );
}

class _CreateLivestockSaleTableIfMissing extends MigrationCommand {
  const _CreateLivestockSaleTableIfMissing();

  @override
  String get statement => '''
CREATE TABLE IF NOT EXISTS `BrickLivestockSaleModel` (
  `_brick_id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `local_id` VARCHAR NULL,
  `establishment_id` VARCHAR NULL,
  `operation_date` DATETIME NULL,
  `buyer_type` VARCHAR NULL,
  `buyer_name` VARCHAR NULL,
  `is_company` BOOLEAN NULL,
  `buyer_last_name` VARCHAR NULL,
  `dte_number` VARCHAR NULL,
  `sale_type` VARCHAR NULL,
  `total_weight_kg` VARCHAR NULL,
  `price_per_kg` VARCHAR NULL,
  `total_amount` VARCHAR NULL,
  `observations` VARCHAR NULL,
  `animal_ids_json` VARCHAR NULL,
  `payment_condition` VARCHAR NULL,
  `initial_payment_json` VARCHAR NULL,
  `created_at` DATETIME NULL,
  `updated_at` DATETIME NULL,
  `deleted_at` DATETIME NULL,
  `sync_status` INTEGER NULL,
  `sync_error_code` VARCHAR NULL
)
''';

  @override
  String get forGenerator => '_CreateLivestockSaleTableIfMissing()';
}
