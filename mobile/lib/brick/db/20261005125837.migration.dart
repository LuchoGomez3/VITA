// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261005125837_up = [
  InsertColumn('lot_movement_id', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('lot_sync_status', Column.integer, onTable: 'BrickAnimalModel'),
  InsertColumn('lot_sync_error_code', Column.varchar, onTable: 'BrickAnimalModel')
];

const List<MigrationCommand> _migration_20261005125837_down = [
  DropColumn('lot_movement_id', onTable: 'BrickAnimalModel'),
  DropColumn('lot_sync_status', onTable: 'BrickAnimalModel'),
  DropColumn('lot_sync_error_code', onTable: 'BrickAnimalModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261005125837',
  up: _migration_20261005125837_up,
  down: _migration_20261005125837_down,
)
class Migration20261005125837 extends Migration {
  const Migration20261005125837()
    : super(
        version: 20261005125837,
        up: _migration_20261005125837_up,
        down: _migration_20261005125837_down,
      );
}
