import 'dart:convert';

import 'package:brick_rest/brick_rest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

void main() {
  test('envía la categoría en la raíz del POST esperado por FastAPI', () async {
    late Request request;
    final provider = _provider((captured) {
      request = captured;
      return _successResponse(captured);
    });
    final timestamp = DateTime.utc(2026, 8, 12, 21, 30);

    await provider.upsert<BrickOperatingExpenseCategoryModel>(
      BrickOperatingExpenseCategoryModel(
        localId: '3e3ded56-4b70-48d2-bce1-971cab45d243',
        establishmentId: 'e35a810e-2740-4ca0-a387-e4aa372dac69',
        type: 'costo_produccion',
        name: 'Mantenimiento de mangas',
        value: 'mantenimiento_de_mangas',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final body = jsonDecode(request.body) as Map<String, dynamic>;
    expect(body['data'], isNull);
    expect(body['id'], '3e3ded56-4b70-48d2-bce1-971cab45d243');
    expect(body['establecimiento_id'], 'e35a810e-2740-4ca0-a387-e4aa372dac69');
    expect(body['tipo'], 'costo_produccion');
    expect(body['nombre'], 'Mantenimiento de mangas');
    expect(body.containsKey('valor'), isFalse);
  });

  test('envía el egreso en la raíz y conserva el monto decimal', () async {
    late Request request;
    final provider = _provider((captured) {
      request = captured;
      return _successResponse(captured);
    });
    final timestamp = DateTime.utc(2026, 8, 12, 21, 30);

    await provider.upsert<BrickOperatingExpenseModel>(
      BrickOperatingExpenseModel(
        localId: 'da7828ae-e80f-4b4f-bb49-c6949bfe6dca',
        establishmentId: 'e35a810e-2740-4ca0-a387-e4aa372dac69',
        amount: '150000.00',
        type: 'costo_produccion',
        category: 'sanidad',
        supply: 'Vacunas reproductivas',
        date: DateTime(2026, 8, 12),
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final body = jsonDecode(request.body) as Map<String, dynamic>;
    expect(body['data'], isNull);
    expect(body['monto'], '150000.00');
    expect(body['fecha'], '2026-08-12');
    expect(body['cargado_por_id'], isNull);
  });
}

RestProvider _provider(Future<Response> Function(Request) handler) {
  return RestProvider(
    'http://localhost:8000',
    modelDictionary: restModelDictionary,
    client: MockClient(handler),
  );
}

Future<Response> _successResponse(Request request) async {
  return Response('{"success":true,"data":{}}', 201, request: request);
}
