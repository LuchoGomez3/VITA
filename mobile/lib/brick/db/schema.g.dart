// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20260622053112.migration.dart';
part '20260623151524.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20260622053112(),
  const Migration20260623151524(),
};

/// A consumable database structure including the latest generated migration.
final schema = Schema(
  20260623151524,
  generatorVersion: 1,
  tables: <SchemaTable>{
    SchemaTable(
      'BrickAnimalModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('local_id', Column.varchar),
        SchemaColumn('rfid_tag_number', Column.varchar),
        SchemaColumn('visual_tag', Column.varchar),
        SchemaColumn('sex', Column.integer),
        SchemaColumn('breed', Column.varchar),
        SchemaColumn('birth_date', Column.datetime),
        SchemaColumn('category_id', Column.varchar),
        SchemaColumn('category_name', Column.varchar),
        SchemaColumn('lot_id', Column.varchar),
        SchemaColumn('lot_name', Column.varchar),
        SchemaColumn('establishment_id', Column.varchar),
        SchemaColumn('initial_weight', Column.Double),
        SchemaColumn('weighing_method', Column.integer),
        SchemaColumn('weighing_date', Column.datetime),
        SchemaColumn('mother_id', Column.varchar),
        SchemaColumn('father_id', Column.varchar),
        SchemaColumn('coat', Column.varchar),
        SchemaColumn('observations', Column.varchar),
        SchemaColumn('sync_status', Column.integer),
        SchemaColumn('sync_error_code', Column.varchar),
        SchemaColumn('created_at', Column.datetime),
        SchemaColumn('updated_at', Column.datetime),
        SchemaColumn('deleted_at', Column.datetime),
      },
      indices: <SchemaIndex>{},
    ),
  },
);
