// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260917120957_up = [
  DropColumn('establishment_id', onTable: 'BrickCategoriaModel')
];

const List<MigrationCommand> _migration_20260917120957_down = [
  
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260917120957',
  up: _migration_20260917120957_up,
  down: _migration_20260917120957_down,
)
class Migration20260917120957 extends Migration {
  const Migration20260917120957()
    : super(
        version: 20260917120957,
        up: _migration_20260917120957_up,
        down: _migration_20260917120957_down,
      );
}
