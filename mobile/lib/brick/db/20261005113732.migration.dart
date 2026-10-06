// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261005113732_up = [
  InsertTable('BrickAnimalUpdateModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickAnimalUpdateModel'),
  InsertColumn('category_id', Column.varchar, onTable: 'BrickAnimalUpdateModel'),
  InsertColumn('status', Column.varchar, onTable: 'BrickAnimalUpdateModel'),
  InsertColumn('reproductive_status', Column.varchar, onTable: 'BrickAnimalUpdateModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickAnimalUpdateModel')
];

const List<MigrationCommand> _migration_20261005113732_down = [
  DropTable('BrickAnimalUpdateModel'),
  DropColumn('local_id', onTable: 'BrickAnimalUpdateModel'),
  DropColumn('category_id', onTable: 'BrickAnimalUpdateModel'),
  DropColumn('status', onTable: 'BrickAnimalUpdateModel'),
  DropColumn('reproductive_status', onTable: 'BrickAnimalUpdateModel'),
  DropColumn('updated_at', onTable: 'BrickAnimalUpdateModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261005113732',
  up: _migration_20261005113732_up,
  down: _migration_20261005113732_down,
)
class Migration20261005113732 extends Migration {
  const Migration20261005113732()
    : super(
        version: 20261005113732,
        up: _migration_20261005113732_up,
        down: _migration_20261005113732_down,
      );
}
