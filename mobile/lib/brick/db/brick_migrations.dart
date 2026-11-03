import 'package:brick_sqlite/db.dart';
import 'package:frontend_mayoral/brick/db/schema.g.dart' as generated;

const _livestockSaleMigrationVersion = 20261028002455;

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
