// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260929235729_up = [
  InsertColumn('productive_status', Column.varchar, onTable: 'BrickAnimalModel')
];

const List<MigrationCommand> _migration_20260929235729_down = [
  DropColumn('productive_status', onTable: 'BrickAnimalModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260929235729',
  up: _migration_20260929235729_up,
  down: _migration_20260929235729_down,
)
class Migration20260929235729 extends Migration {
  const Migration20260929235729()
    : super(
        version: 20260929235729,
        up: _migration_20260929235729_up,
        down: _migration_20260929235729_down,
      );
}
