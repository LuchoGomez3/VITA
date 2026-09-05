// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260828160014_up = [
  InsertTable('BrickLotModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickLotModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickLotModel'),
  InsertColumn('name', Column.varchar, onTable: 'BrickLotModel'),
  InsertColumn('boundary_json', Column.varchar, onTable: 'BrickLotModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickLotModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickLotModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickLotModel'),
];

const List<MigrationCommand> _migration_20260828160014_down = [
  DropTable('BrickLotModel'),
  DropColumn('local_id', onTable: 'BrickLotModel'),
  DropColumn('establishment_id', onTable: 'BrickLotModel'),
  DropColumn('name', onTable: 'BrickLotModel'),
  DropColumn('boundary_json', onTable: 'BrickLotModel'),
  DropColumn('created_at', onTable: 'BrickLotModel'),
  DropColumn('updated_at', onTable: 'BrickLotModel'),
  DropColumn('deleted_at', onTable: 'BrickLotModel'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260828160014',
  up: _migration_20260828160014_up,
  down: _migration_20260828160014_down,
)
class Migration20260828160014 extends Migration {
  const Migration20260828160014()
    : super(
        version: 20260828160014,
        up: _migration_20260828160014_up,
        down: _migration_20260828160014_down,
      );
}
