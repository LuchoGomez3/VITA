// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260830204306_up = [
  InsertTable('BrickAnimalLotMovementModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('source_lot_id', Column.varchar, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('destination_lot_id', Column.varchar, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('animal_ids_json', Column.varchar, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('occurred_at', Column.datetime, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('reason', Column.varchar, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('responsible_id', Column.varchar, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickAnimalLotMovementModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickAnimalLotMovementModel'),
];

const List<MigrationCommand> _migration_20260830204306_down = [
  DropTable('BrickAnimalLotMovementModel'),
  DropColumn('local_id', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('establishment_id', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('source_lot_id', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('destination_lot_id', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('animal_ids_json', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('occurred_at', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('reason', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('responsible_id', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('created_at', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('updated_at', onTable: 'BrickAnimalLotMovementModel'),
  DropColumn('deleted_at', onTable: 'BrickAnimalLotMovementModel'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260830204306',
  up: _migration_20260830204306_up,
  down: _migration_20260830204306_down,
)
class Migration20260830204306 extends Migration {
  const Migration20260830204306()
    : super(
        version: 20260830204306,
        up: _migration_20260830204306_up,
        down: _migration_20260830204306_down,
      );
}
