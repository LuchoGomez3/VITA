// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261120223303_up = [
  InsertTable('BrickHealthCatalogModel'),
  InsertTable('BrickHealthEventModel'),
  InsertTable('BrickHealthOperationModel'),
  InsertColumn('local_registration_author_id', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickHealthCatalogModel', unique: true),
  InsertColumn('payload', Column.varchar, onTable: 'BrickHealthCatalogModel'),
  InsertColumn('cursor', Column.varchar, onTable: 'BrickHealthCatalogModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickHealthEventModel', unique: true),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickHealthEventModel'),
  InsertColumn('animal_id', Column.varchar, onTable: 'BrickHealthEventModel'),
  InsertColumn('payload', Column.varchar, onTable: 'BrickHealthEventModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickHealthOperationModel', unique: true),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickHealthOperationModel'),
  InsertColumn('author_id', Column.varchar, onTable: 'BrickHealthOperationModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickHealthOperationModel'),
  InsertColumn('payload', Column.varchar, onTable: 'BrickHealthOperationModel'),
  InsertColumn('result_event_id', Column.varchar, onTable: 'BrickHealthOperationModel'),
  InsertColumn('rejection', Column.varchar, onTable: 'BrickHealthOperationModel')
];

const List<MigrationCommand> _migration_20261120223303_down = [
  DropTable('BrickHealthCatalogModel'),
  DropTable('BrickHealthEventModel'),
  DropTable('BrickHealthOperationModel'),
  DropColumn('local_registration_author_id', onTable: 'BrickAnimalModel'),
  DropColumn('establishment_id', onTable: 'BrickHealthCatalogModel'),
  DropColumn('payload', onTable: 'BrickHealthCatalogModel'),
  DropColumn('cursor', onTable: 'BrickHealthCatalogModel'),
  DropColumn('local_id', onTable: 'BrickHealthEventModel'),
  DropColumn('establishment_id', onTable: 'BrickHealthEventModel'),
  DropColumn('animal_id', onTable: 'BrickHealthEventModel'),
  DropColumn('payload', onTable: 'BrickHealthEventModel'),
  DropColumn('local_id', onTable: 'BrickHealthOperationModel'),
  DropColumn('establishment_id', onTable: 'BrickHealthOperationModel'),
  DropColumn('author_id', onTable: 'BrickHealthOperationModel'),
  DropColumn('created_at', onTable: 'BrickHealthOperationModel'),
  DropColumn('payload', onTable: 'BrickHealthOperationModel'),
  DropColumn('result_event_id', onTable: 'BrickHealthOperationModel'),
  DropColumn('rejection', onTable: 'BrickHealthOperationModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261120223303',
  up: _migration_20261120223303_up,
  down: _migration_20261120223303_down,
)
class Migration20261120223303 extends Migration {
  const Migration20261120223303()
    : super(
        version: 20261120223303,
        up: _migration_20261120223303_up,
        down: _migration_20261120223303_down,
      );
}
