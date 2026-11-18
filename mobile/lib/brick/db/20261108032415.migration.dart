// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20261108032415_up = [
  InsertColumn('pending_animal_ids_json', Column.varchar, onTable: 'BrickLivestockSaleModel'),
];

const List<MigrationCommand> _migration_20261108032415_down = [
  DropColumn('pending_animal_ids_json', onTable: 'BrickLivestockSaleModel'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20261108032415',
  up: _migration_20261108032415_up,
  down: _migration_20261108032415_down,
)
class Migration20261108032415 extends Migration {
  const Migration20261108032415()
    : super(
        version: 20261108032415,
        up: _migration_20261108032415_up,
        down: _migration_20261108032415_down,
      );
}
