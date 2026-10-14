// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260622053112_up = [
  InsertTable('BrickAnimalModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('rfid_tag_number', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('visual_tag', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('sex', Column.integer, onTable: 'BrickAnimalModel'),
  InsertColumn('breed', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('birth_date', Column.datetime, onTable: 'BrickAnimalModel'),
  InsertColumn('category_id', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('category_name', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('lot_id', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('lot_name', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('initial_weight', Column.Double, onTable: 'BrickAnimalModel'),
  InsertColumn('weighing_method', Column.integer, onTable: 'BrickAnimalModel'),
  InsertColumn('weighing_date', Column.datetime, onTable: 'BrickAnimalModel'),
  InsertColumn('mother_id', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('father_id', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('coat', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('observations', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickAnimalModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickAnimalModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickAnimalModel'),
];

const List<MigrationCommand> _migration_20260622053112_down = [
  DropTable('BrickAnimalModel'),
  DropColumn('local_id', onTable: 'BrickAnimalModel'),
  DropColumn('rfid_tag_number', onTable: 'BrickAnimalModel'),
  DropColumn('visual_tag', onTable: 'BrickAnimalModel'),
  DropColumn('sex', onTable: 'BrickAnimalModel'),
  DropColumn('breed', onTable: 'BrickAnimalModel'),
  DropColumn('birth_date', onTable: 'BrickAnimalModel'),
  DropColumn('category_id', onTable: 'BrickAnimalModel'),
  DropColumn('category_name', onTable: 'BrickAnimalModel'),
  DropColumn('lot_id', onTable: 'BrickAnimalModel'),
  DropColumn('lot_name', onTable: 'BrickAnimalModel'),
  DropColumn('establishment_id', onTable: 'BrickAnimalModel'),
  DropColumn('initial_weight', onTable: 'BrickAnimalModel'),
  DropColumn('weighing_method', onTable: 'BrickAnimalModel'),
  DropColumn('weighing_date', onTable: 'BrickAnimalModel'),
  DropColumn('mother_id', onTable: 'BrickAnimalModel'),
  DropColumn('father_id', onTable: 'BrickAnimalModel'),
  DropColumn('coat', onTable: 'BrickAnimalModel'),
  DropColumn('observations', onTable: 'BrickAnimalModel'),
  DropColumn('sync_status', onTable: 'BrickAnimalModel'),
  DropColumn('sync_error_code', onTable: 'BrickAnimalModel'),
  DropColumn('created_at', onTable: 'BrickAnimalModel'),
  DropColumn('updated_at', onTable: 'BrickAnimalModel'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260622053112',
  up: _migration_20260622053112_up,
  down: _migration_20260622053112_down,
)
class Migration20260622053112 extends Migration {
  const Migration20260622053112()
    : super(
        version: 20260622053112,
        up: _migration_20260622053112_up,
        down: _migration_20260622053112_down,
      );
}
