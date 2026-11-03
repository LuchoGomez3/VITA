import 'dart:convert';

import 'package:brick_rest/brick_rest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

void main() {
  test('envía el contrato de lote vigente del backend', () async {
    late Request request;
    final provider = RestProvider(
      'http://localhost:8000',
      modelDictionary: restModelDictionary,
      client: MockClient((captured) async {
        request = captured;
        return Response('{"success":true,"data":{}}', 201);
      }),
    );
    final timestamp = DateTime.utc(2026, 9, 5, 12);

    await provider.upsert<BrickLotModel>(
      BrickLotModel(
        localId: '1c1b12e1-243b-44ea-9cf8-57d15fefca02',
        establishmentId: 'fe5f93ba-fc82-40b0-9c57-1966fe4b48a4',
        name: 'Potrero Bajo',
        boundaryJson: jsonEncode({
          'type': 'LocalPolygon',
          'coordinate_space': 'establishment_canvas_v1',
          'version': 1,
          'extent': {'width': 1000.0, 'height': 1000.0},
          'vertices': [
            {'x': 0.0, 'y': 0.0},
            {'x': 10.0, 'y': 0.0},
            {'x': 0.0, 'y': 10.0},
          ],
        }),
        surfaceTenths: 457,
        hasWater: true,
        statusCode: 'activo',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final body = jsonDecode(request.body) as Map<String, dynamic>;
    expect(body['modo_geometria'], 'local_schematic');
    expect(body.containsKey('geometry_mode'), isFalse);
    expect(body['estado'], 'activo');
    expect(body['superficie_ha'], 45.7);
  });

  test('arma el pull de movimientos con el establecimiento requerido', () {
    final request = BrickAnimalLotMovementRequestTransformer.listByEstablishmentRequest(
      'establishment id',
    );

    expect(
      request.url,
      '/api/v1/movimientos_lotes?establecimiento_id=establishment+id&include_deleted=true',
    );
    expect(request.topLevelKey, 'data');
  });
}
