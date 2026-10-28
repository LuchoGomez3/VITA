// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// Esta version nacio en la rama original de ventas. Se conserva como version
// canonica para que los dispositivos que ya la aplicaron no intenten agregar
// productive_status nuevamente al integrarse con develop.
const List<MigrationCommand> _migration_20261014141500_up = [
  InsertColumn('productive_status', Column.varchar, onTable: 'BrickAnimalModel'),
];

const List<MigrationCommand> _migration_20261014141500_down = [
  DropColumn('productive_status', onTable: 'BrickAnimalModel'),
];

@Migratable(
  version: '20261014141500',
  up: _migration_20261014141500_up,
  down: _migration_20261014141500_down,
)
class Migration20261014141500 extends Migration {
  const Migration20261014141500()
    : super(
        version: 20261014141500,
        up: _migration_20261014141500_up,
        down: _migration_20261014141500_down,
      );
}
