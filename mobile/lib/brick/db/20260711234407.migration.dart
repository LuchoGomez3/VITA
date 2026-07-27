// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260711234407_up = [
  InsertTable('BrickCategoriaModel'),
  InsertTable('BrickPesajeModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickCategoriaModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickCategoriaModel'),
  InsertColumn('name', Column.varchar, onTable: 'BrickCategoriaModel'),
  InsertColumn('description', Column.varchar, onTable: 'BrickCategoriaModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickCategoriaModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickCategoriaModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickCategoriaModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickCategoriaModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickCategoriaModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickPesajeModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickPesajeModel'),
  InsertColumn('animal_id', Column.varchar, onTable: 'BrickPesajeModel'),
  InsertColumn('weight_kg', Column.Double, onTable: 'BrickPesajeModel'),
  InsertColumn('date', Column.datetime, onTable: 'BrickPesajeModel'),
  InsertColumn('method', Column.integer, onTable: 'BrickPesajeModel'),
  InsertColumn('is_estimated', Column.boolean, onTable: 'BrickPesajeModel'),
  InsertColumn('body_condition', Column.Double, onTable: 'BrickPesajeModel'),
  InsertColumn('photo_url', Column.varchar, onTable: 'BrickPesajeModel'),
  InsertColumn('responsible_id', Column.varchar, onTable: 'BrickPesajeModel'),
  InsertColumn('observations', Column.varchar, onTable: 'BrickPesajeModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickPesajeModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickPesajeModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickPesajeModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickPesajeModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickPesajeModel')
];

const List<MigrationCommand> _migration_20260711234407_down = [
  DropTable('BrickCategoriaModel'),
  DropTable('BrickPesajeModel'),
  DropColumn('local_id', onTable: 'BrickCategoriaModel'),
  DropColumn('establishment_id', onTable: 'BrickCategoriaModel'),
  DropColumn('name', onTable: 'BrickCategoriaModel'),
  DropColumn('description', onTable: 'BrickCategoriaModel'),
  DropColumn('sync_status', onTable: 'BrickCategoriaModel'),
  DropColumn('sync_error_code', onTable: 'BrickCategoriaModel'),
  DropColumn('created_at', onTable: 'BrickCategoriaModel'),
  DropColumn('updated_at', onTable: 'BrickCategoriaModel'),
  DropColumn('deleted_at', onTable: 'BrickCategoriaModel'),
  DropColumn('local_id', onTable: 'BrickPesajeModel'),
  DropColumn('establishment_id', onTable: 'BrickPesajeModel'),
  DropColumn('animal_id', onTable: 'BrickPesajeModel'),
  DropColumn('weight_kg', onTable: 'BrickPesajeModel'),
  DropColumn('date', onTable: 'BrickPesajeModel'),
  DropColumn('method', onTable: 'BrickPesajeModel'),
  DropColumn('is_estimated', onTable: 'BrickPesajeModel'),
  DropColumn('body_condition', onTable: 'BrickPesajeModel'),
  DropColumn('photo_url', onTable: 'BrickPesajeModel'),
  DropColumn('responsible_id', onTable: 'BrickPesajeModel'),
  DropColumn('observations', onTable: 'BrickPesajeModel'),
  DropColumn('sync_status', onTable: 'BrickPesajeModel'),
  DropColumn('sync_error_code', onTable: 'BrickPesajeModel'),
  DropColumn('created_at', onTable: 'BrickPesajeModel'),
  DropColumn('updated_at', onTable: 'BrickPesajeModel'),
  DropColumn('deleted_at', onTable: 'BrickPesajeModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260711234407',
  up: _migration_20260711234407_up,
  down: _migration_20260711234407_down,
)
class Migration20260711234407 extends Migration {
  const Migration20260711234407()
    : super(
        version: 20260711234407,
        up: _migration_20260711234407_up,
        down: _migration_20260711234407_down,
      );
}
