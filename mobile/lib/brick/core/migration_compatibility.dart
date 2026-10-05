import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart';

/// Adapta la restauración de categorías a bases creadas en ambas ramas.
///
/// Algunas instalaciones nunca ejecutaron las migraciones que retiraban estas
/// columnas. Conservamos las que ya existen y agregamos solamente las faltantes;
/// Brick sigue registrando la versión original, sin borrar datos ni saltar otras
/// migraciones. También permite reintentar una ejecución parcialmente completada.
Future<Set<Migration>> resolveCompatibleMigrations(
  SqliteProvider provider,
  Iterable<Migration> migrations,
) async {
  final columns = await provider.rawQuery('PRAGMA table_info("BrickCategoriaModel")');
  final names = columns.map((column) => column['name']).toSet();
  return migrations.map((migration) {
    if (migration.version != 20261005193219) return migration;
    return _CompatibleMigration(
      migration,
      migration.up.where((command) => command is! InsertColumn || !names.contains(command.name)).toList(),
    );
  }).toSet();
}

/// Mantiene la identidad de la migración para que Brick confirme su versión.
class _CompatibleMigration extends Migration {
  _CompatibleMigration(Migration original, List<MigrationCommand> commands)
    : super(version: original.version, up: commands, down: original.down);
}
