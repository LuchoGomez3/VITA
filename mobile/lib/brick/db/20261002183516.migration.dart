// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261002183516_up = [
  InsertColumn('sync_status', Column.integer, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickAnimalLotMovementModel')
];

const List<MigrationCommand> _migration_20261002183516_down = [
  DropColumn('sync_status', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('sync_error_code', onTable: 'BrickAnimalLotMovementModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261002183516',
  up: _migration_20261002183516_up,
  down: _migration_20261002183516_down,
)
class Migration20261002183516 extends Migration {
  const Migration20261002183516()
    : super(
        version: 20261002183516,
        up: _migration_20261002183516_up,
        down: _migration_20261002183516_down,
      );
}
