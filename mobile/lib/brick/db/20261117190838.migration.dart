// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261117190838_up = [
  InsertTable('BrickLotForagePeriodModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('lot_id', Column.varchar, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('forage_resource_code', Column.varchar, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('description', Column.varchar, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('start_date', Column.varchar, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('end_date', Column.varchar, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('registered_by_id', Column.varchar, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickLotForagePeriodModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickLotForagePeriodModel')
];

const List<MigrationCommand> _migration_20261117190838_down = [
  DropTable('BrickLotForagePeriodModel'),
  DropColumn('local_id', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('establishment_id', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('lot_id', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('forage_resource_code', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('description', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('start_date', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('end_date', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('registered_by_id', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('created_at', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('updated_at', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('deleted_at', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('sync_status', onTable: 'BrickLotForagePeriodModel'),
  DropColumn('sync_error_code', onTable: 'BrickLotForagePeriodModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261117190838',
  up: _migration_20261117190838_up,
  down: _migration_20261117190838_down,
)
class Migration20261117190838 extends Migration {
  const Migration20261117190838()
    : super(
        version: 20261117190838,
        up: _migration_20261117190838_up,
        down: _migration_20261117190838_down,
      );
}
