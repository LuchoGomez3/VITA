// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

const List<MigrationCommand> _migration_20261028002455_up = [
  InsertTable('BrickLivestockSaleModel'),
  InsertColumn('local_id', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('establishment_id', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('operation_date', Column.datetime, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('buyer_type', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('buyer_name', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('is_company', Column.boolean, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('buyer_last_name', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('dte_number', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('sale_type', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('total_weight_kg', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('price_per_kg', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('total_amount', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('observations', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('animal_ids_json', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('payment_condition', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('initial_payment_json', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('created_at', Column.datetime, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('deleted_at', Column.datetime, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('sync_status', Column.integer, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('sync_error_code', Column.varchar, onTable: 'BrickLivestockSaleModel'),
];

const List<MigrationCommand> _migration_20261028002455_down = [
  DropTable('BrickLivestockSaleModel'),
  DropColumn('local_id', onTable: 'BrickLivestockSaleModel'),
  DropColumn('establishment_id', onTable: 'BrickLivestockSaleModel'),
  DropColumn('operation_date', onTable: 'BrickLivestockSaleModel'),
  DropColumn('buyer_type', onTable: 'BrickLivestockSaleModel'),
  DropColumn('buyer_name', onTable: 'BrickLivestockSaleModel'),
  DropColumn('is_company', onTable: 'BrickLivestockSaleModel'),
  DropColumn('buyer_last_name', onTable: 'BrickLivestockSaleModel'),
  DropColumn('dte_number', onTable: 'BrickLivestockSaleModel'),
  DropColumn('sale_type', onTable: 'BrickLivestockSaleModel'),
  DropColumn('total_weight_kg', onTable: 'BrickLivestockSaleModel'),
  DropColumn('price_per_kg', onTable: 'BrickLivestockSaleModel'),
  DropColumn('total_amount', onTable: 'BrickLivestockSaleModel'),
  DropColumn('observations', onTable: 'BrickLivestockSaleModel'),
  DropColumn('animal_ids_json', onTable: 'BrickLivestockSaleModel'),
  DropColumn('payment_condition', onTable: 'BrickLivestockSaleModel'),
  DropColumn('initial_payment_json', onTable: 'BrickLivestockSaleModel'),
  DropColumn('created_at', onTable: 'BrickLivestockSaleModel'),
  DropColumn('updated_at', onTable: 'BrickLivestockSaleModel'),
  DropColumn('deleted_at', onTable: 'BrickLivestockSaleModel'),
  DropColumn('sync_status', onTable: 'BrickLivestockSaleModel'),
  DropColumn('sync_error_code', onTable: 'BrickLivestockSaleModel'),
];

@Migratable(
  version: '20261028002455',
  up: _migration_20261028002455_up,
  down: _migration_20261028002455_down,
)
class Migration20261028002455 extends Migration {
  const Migration20261028002455()
    : super(
        version: 20261028002455,
        up: _migration_20261028002455_up,
        down: _migration_20261028002455_down,
      );
}
