// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260812200326_up = [
  InsertTable('BrickOperatingExpenseModel'),
  InsertTable('BrickOperatingExpenseCategoryModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('amount', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('type', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('category', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('supply', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('date', Column.datetime, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('description', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('receipt_number', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('loaded_by_id', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('loaded_by_name', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('custom_category_id', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickOperatingExpenseModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickOperatingExpenseCategoryModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickOperatingExpenseCategoryModel'),
  InsertColumn('type', Column.varchar, onTable: 'BrickOperatingExpenseCategoryModel'),
  InsertColumn('name', Column.varchar, onTable: 'BrickOperatingExpenseCategoryModel'),
  InsertColumn('value', Column.varchar, onTable: 'BrickOperatingExpenseCategoryModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickOperatingExpenseCategoryModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickOperatingExpenseCategoryModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickOperatingExpenseCategoryModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickOperatingExpenseCategoryModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickOperatingExpenseCategoryModel')
];

const List<MigrationCommand> _migration_20260812200326_down = [
  DropTable('BrickOperatingExpenseModel'),
  DropTable('BrickOperatingExpenseCategoryModel'),
  DropColumn('local_id', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('establishment_id', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('amount', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('type', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('category', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('supply', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('date', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('description', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('receipt_number', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('loaded_by_id', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('loaded_by_name', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('created_at', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('updated_at', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('deleted_at', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('custom_category_id', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('sync_status', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('sync_error_code', onTable: 'BrickOperatingExpenseModel'),
  DropColumn('local_id', onTable: 'BrickOperatingExpenseCategoryModel'),
  DropColumn('establishment_id', onTable: 'BrickOperatingExpenseCategoryModel'),
  DropColumn('type', onTable: 'BrickOperatingExpenseCategoryModel'),
  DropColumn('name', onTable: 'BrickOperatingExpenseCategoryModel'),
  DropColumn('value', onTable: 'BrickOperatingExpenseCategoryModel'),
  DropColumn('created_at', onTable: 'BrickOperatingExpenseCategoryModel'),
  DropColumn('updated_at', onTable: 'BrickOperatingExpenseCategoryModel'),
  DropColumn('deleted_at', onTable: 'BrickOperatingExpenseCategoryModel'),
  DropColumn('sync_status', onTable: 'BrickOperatingExpenseCategoryModel'),
  DropColumn('sync_error_code', onTable: 'BrickOperatingExpenseCategoryModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260812200326',
  up: _migration_20260812200326_up,
  down: _migration_20260812200326_down,
)
class Migration20260812200326 extends Migration {
  const Migration20260812200326()
    : super(
        version: 20260812200326,
        up: _migration_20260812200326_up,
        down: _migration_20260812200326_down,
      );
}
