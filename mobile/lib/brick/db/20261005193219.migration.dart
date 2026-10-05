// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261005193219_up = [
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickCategoriaModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickCategoriaModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickCategoriaModel')
];

const List<MigrationCommand> _migration_20261005193219_down = [
  DropColumn('establishment_id', onTable: 'BrickCategoriaModel'),
  DropColumn('sync_status', onTable: 'BrickCategoriaModel'),
  DropColumn('sync_error_code', onTable: 'BrickCategoriaModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261005193219',
  up: _migration_20261005193219_up,
  down: _migration_20261005193219_down,
)
class Migration20261005193219 extends Migration {
  const Migration20261005193219()
    : super(
        version: 20261005193219,
        up: _migration_20261005193219_up,
        down: _migration_20261005193219_down,
      );
}
