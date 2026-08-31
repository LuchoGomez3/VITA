// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260830203237_up = [
  InsertColumn('geometry_mode', Column.varchar, onTable: 'BrickLotModel'),
];

const List<MigrationCommand> _migration_20260830203237_down = [DropColumn('geometry_mode', onTable: 'BrickLotModel')];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260830203237',
  up: _migration_20260830203237_up,
  down: _migration_20260830203237_down,
)
class Migration20260830203237 extends Migration {
  const Migration20260830203237()
    : super(
        version: 20260830203237,
        up: _migration_20260830203237_up,
        down: _migration_20260830203237_down,
      );
}
