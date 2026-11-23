// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261123003833_up = [
  InsertColumn('allowed_sex', Column.varchar, onTable: 'BrickCategoriaModel')
];

const List<MigrationCommand> _migration_20261123003833_down = [
  DropColumn('allowed_sex', onTable: 'BrickCategoriaModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261123003833',
  up: _migration_20261123003833_up,
  down: _migration_20261123003833_down,
)
class Migration20261123003833 extends Migration {
  const Migration20261123003833()
    : super(
        version: 20261123003833,
        up: _migration_20261123003833_up,
        down: _migration_20261123003833_down,
      );
}
