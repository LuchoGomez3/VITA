// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261123235738_up = [
  InsertTable('BrickAnimalObservationModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('animal_id', Column.varchar, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('text', Column.varchar, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('date', Column.datetime, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('author_id', Column.varchar, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickAnimalObservationModel')
];

const List<MigrationCommand> _migration_20261123235738_down = [
  DropTable('BrickAnimalObservationModel'),
  DropColumn('local_id', onTable: 'BrickAnimalObservationModel'),
  DropColumn('establishment_id', onTable: 'BrickAnimalObservationModel'),
  DropColumn('animal_id', onTable: 'BrickAnimalObservationModel'),
  DropColumn('text', onTable: 'BrickAnimalObservationModel'),
  DropColumn('date', onTable: 'BrickAnimalObservationModel'),
  DropColumn('author_id', onTable: 'BrickAnimalObservationModel'),
  DropColumn('sync_status', onTable: 'BrickAnimalObservationModel'),
  DropColumn('sync_error_code', onTable: 'BrickAnimalObservationModel'),
  DropColumn('created_at', onTable: 'BrickAnimalObservationModel'),
  DropColumn('updated_at', onTable: 'BrickAnimalObservationModel'),
  DropColumn('deleted_at', onTable: 'BrickAnimalObservationModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261123235738',
  up: _migration_20261123235738_up,
  down: _migration_20261123235738_down,
)
class Migration20261123235738 extends Migration {
  const Migration20261123235738()
    : super(
        version: 20261123235738,
        up: _migration_20261123235738_up,
        down: _migration_20261123235738_down,
      );
}
