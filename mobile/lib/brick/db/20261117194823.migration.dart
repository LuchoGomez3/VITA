// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261117194823_up = [
  InsertTable('BrickFeedingRecordModel'),
  InsertTable('BrickFoodModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('type', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('food_id', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('lot_id', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('start_date', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('end_date', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('quantity', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('unit', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('quantity_basis', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('reason', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('animal_ids_json', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('responsible_id', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickFeedingRecordModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickFoodModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickFoodModel'),
  InsertColumn('name', Column.varchar, onTable: 'BrickFoodModel'),
  InsertColumn('category', Column.varchar, onTable: 'BrickFoodModel'),
  InsertColumn('unit', Column.varchar, onTable: 'BrickFoodModel'),
  InsertColumn('created_by_id', Column.varchar, onTable: 'BrickFoodModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickFoodModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickFoodModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickFoodModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickFoodModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickFoodModel')
];

const List<MigrationCommand> _migration_20261117194823_down = [
  DropTable('BrickFeedingRecordModel'),
  DropTable('BrickFoodModel'),
  DropColumn('local_id', onTable: 'BrickFeedingRecordModel'),
  DropColumn('establishment_id', onTable: 'BrickFeedingRecordModel'),
  DropColumn('type', onTable: 'BrickFeedingRecordModel'),
  DropColumn('food_id', onTable: 'BrickFeedingRecordModel'),
  DropColumn('lot_id', onTable: 'BrickFeedingRecordModel'),
  DropColumn('start_date', onTable: 'BrickFeedingRecordModel'),
  DropColumn('end_date', onTable: 'BrickFeedingRecordModel'),
  DropColumn('quantity', onTable: 'BrickFeedingRecordModel'),
  DropColumn('unit', onTable: 'BrickFeedingRecordModel'),
  DropColumn('quantity_basis', onTable: 'BrickFeedingRecordModel'),
  DropColumn('reason', onTable: 'BrickFeedingRecordModel'),
  DropColumn('animal_ids_json', onTable: 'BrickFeedingRecordModel'),
  DropColumn('responsible_id', onTable: 'BrickFeedingRecordModel'),
  DropColumn('created_at', onTable: 'BrickFeedingRecordModel'),
  DropColumn('updated_at', onTable: 'BrickFeedingRecordModel'),
  DropColumn('deleted_at', onTable: 'BrickFeedingRecordModel'),
  DropColumn('sync_status', onTable: 'BrickFeedingRecordModel'),
  DropColumn('sync_error_code', onTable: 'BrickFeedingRecordModel'),
  DropColumn('local_id', onTable: 'BrickFoodModel'),
  DropColumn('establishment_id', onTable: 'BrickFoodModel'),
  DropColumn('name', onTable: 'BrickFoodModel'),
  DropColumn('category', onTable: 'BrickFoodModel'),
  DropColumn('unit', onTable: 'BrickFoodModel'),
  DropColumn('created_by_id', onTable: 'BrickFoodModel'),
  DropColumn('created_at', onTable: 'BrickFoodModel'),
  DropColumn('updated_at', onTable: 'BrickFoodModel'),
  DropColumn('deleted_at', onTable: 'BrickFoodModel'),
  DropColumn('sync_status', onTable: 'BrickFoodModel'),
  DropColumn('sync_error_code', onTable: 'BrickFoodModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261117194823',
  up: _migration_20261117194823_up,
  down: _migration_20261117194823_down,
)
class Migration20261117194823 extends Migration {
  const Migration20261117194823()
    : super(
        version: 20261117194823,
        up: _migration_20261117194823_up,
        down: _migration_20261117194823_down,
      );
}
