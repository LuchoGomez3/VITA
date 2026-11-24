// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261124061506_up = [
  InsertColumn('collected_amount', Column.varchar, onTable: 'BrickLivestockSaleModel'),
  InsertColumn('pending_amount', Column.varchar, onTable: 'BrickLivestockSaleModel')
];

const List<MigrationCommand> _migration_20261124061506_down = [
  DropColumn('collected_amount', onTable: 'BrickLivestockSaleModel'),
  DropColumn('pending_amount', onTable: 'BrickLivestockSaleModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261124061506',
  up: _migration_20261124061506_up,
  down: _migration_20261124061506_down,
)
class Migration20261124061506 extends Migration {
  const Migration20261124061506()
    : super(
        version: 20261124061506,
        up: _migration_20261124061506_up,
        down: _migration_20261124061506_down,
      );
}
