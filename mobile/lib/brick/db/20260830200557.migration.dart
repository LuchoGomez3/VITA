// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260830200557_up = [
  InsertColumn('surface_tenths', Column.integer, onTable: 'BrickLotModel'),
  InsertColumn('forage_resource_code', Column.varchar, onTable: 'BrickLotModel'),
  InsertColumn('has_water', Column.boolean, onTable: 'BrickLotModel'),
  InsertColumn('status_code', Column.varchar, onTable: 'BrickLotModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickLotModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickLotModel'),
];

const List<MigrationCommand> _migration_20260830200557_down = [
  DropColumn('surface_tenths', onTable: 'BrickLotModel'),
  DropColumn('forage_resource_code', onTable: 'BrickLotModel'),
  DropColumn('has_water', onTable: 'BrickLotModel'),
  DropColumn('status_code', onTable: 'BrickLotModel'),
  DropColumn('sync_status', onTable: 'BrickLotModel'),
  DropColumn('sync_error_code', onTable: 'BrickLotModel'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260830200557',
  up: _migration_20260830200557_up,
  down: _migration_20260830200557_down,
)
class Migration20260830200557 extends Migration {
  const Migration20260830200557()
    : super(
        version: 20260830200557,
        up: _migration_20260830200557_up,
        down: _migration_20260830200557_down,
      );
}
