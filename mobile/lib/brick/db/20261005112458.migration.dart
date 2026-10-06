// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261005112458_up = [
  InsertTable('BrickAnimalObservationModel'),
  InsertColumn('status', Column.varchar, onTable: 'BrickAnimalModel'),
  InsertColumn('reproductive_status', Column.varchar, onTable: 'BrickAnimalModel'),
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
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickAnimalObservationModel'),
  InsertColumn('allowed_sex', Column.varchar, onTable: 'BrickCategoriaModel'),
  InsertColumn('allows_reproductive_status', Column.boolean, onTable: 'BrickCategoriaModel')
];

const List<MigrationCommand> _migration_20261005112458_down = [
  DropTable('BrickAnimalObservationModel'),
  DropColumn('status', onTable: 'BrickAnimalModel'),
  DropColumn('reproductive_status', onTable: 'BrickAnimalModel'),
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
  DropColumn('deleted_at', onTable: 'BrickAnimalObservationModel'),
  DropColumn('allowed_sex', onTable: 'BrickCategoriaModel'),
  DropColumn('allows_reproductive_status', onTable: 'BrickCategoriaModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261005112458',
  up: _migration_20261005112458_up,
  down: _migration_20261005112458_down,
)
class Migration20261005112458 extends Migration {
  const Migration20261005112458()
    : super(
        version: 20261005112458,
        up: _migration_20261005112458_up,
        down: _migration_20261005112458_down,
      );
}
