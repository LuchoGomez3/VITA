import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/operating_expense_catalog_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('maps only custom financial categories for offline storage', () async {
    final source = OperatingExpenseCatalogRemoteDataSource(
      backendBaseUrl: 'https://example.test',
      client: MockClient(
        (_) async => http.Response(
          '{"data":[{"valor":"costo_produccion","categorias":['
          '{"valor":"sanidad","etiqueta":"Sanidad","personalizada":false},'
          '{"valor":"reparacion","etiqueta":"Reparación","personalizada":true}'
          ']}]}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
      now: () => DateTime.utc(2026, 9, 4),
    );

    final categories = await source.fetchCustomCategories('establishment-id');

    expect(categories, hasLength(1));
    expect(categories.single.value, 'reparacion');
    expect(
      categories.single.syncStatus,
      BrickOperatingExpenseCategorySyncStatus.synchronized,
    );
  });
}
