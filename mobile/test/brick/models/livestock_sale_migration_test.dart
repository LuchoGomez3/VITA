import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/db/schema.g.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('la migracion de ventas permanece registrada en el esquema', () {
    final migration = migrations.singleWhere(
      (item) => item.version == 20261003184650,
    );

    expect(
      migration.upStatement,
      allOf(
        contains('CREATE TABLE IF NOT EXISTS `BrickLivestockSaleModel`'),
        contains('`price_per_kg` VARCHAR NULL'),
        contains('`initial_payment_json` VARCHAR NULL'),
      ),
    );
  });

  test('la migracion crea la tabla local con los campos economicos', () async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    final migration = migrations.singleWhere(
      (item) => item.version == 20261003184650,
    );

    for (final statement in migration.upStatement.split(';')) {
      final sql = statement.trim();
      if (sql.isNotEmpty) {
        await database.execute(sql);
      }
    }

    final columns = await database.rawQuery(
      'PRAGMA table_info(BrickLivestockSaleModel)',
    );
    final names = columns.map((column) => column['name']).toSet();
    expect(
      names,
      containsAll(<String>[
        'local_id',
        'animal_ids_json',
        'total_weight_kg',
        'price_per_kg',
        'total_amount',
        'initial_payment_json',
        'sync_status',
      ]),
    );
  });
}
