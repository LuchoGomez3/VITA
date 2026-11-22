import 'dart:convert';

import 'package:brick_rest/brick_rest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

void main() {
  test('envia la venta completa sin perder precision decimal', () async {
    late Request request;
    final provider = _provider((captured) {
      request = captured;
      return _successResponse(captured);
    });
    final timestamp = DateTime.utc(2026, 10, 3, 18, 30);

    await provider.upsert<BrickLivestockSaleModel>(
      BrickLivestockSaleModel(
        localId: '74d4202e-99e3-431d-826c-ac1e8e366187',
        establishmentId: '5d035241-a780-48f1-a259-fd8eea7025b1',
        operationDate: DateTime(2026, 10, 3),
        buyerType: 'frigorifico',
        buyerName: 'Comprador de prueba SA',
        isCompany: true,
        dteNumber: '001234567-9',
        saleType: 'por_kilo',
        totalWeightKg: '10.125',
        pricePerKg: '1000.123456',
        totalAmount: '10126.24',
        animalIdsJson: jsonEncode([
          '2e4ffc88-aa9d-4b4c-a5e2-d45013cf7346',
          '0a29c84a-485c-4576-903b-f7556774ea19',
        ]),
        paymentCondition: 'parcial',
        initialPaymentJson: jsonEncode({
          'id': '65510387-f31f-450c-b278-d4b254709549',
          'fecha_cobro': '2026-10-03',
          'monto': '5000.10',
          'medio_cobro': 'transferencia',
          'observaciones': null,
          'created_at': timestamp.toIso8601String(),
          'updated_at': timestamp.toIso8601String(),
          'deleted_at': null,
        }),
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final body = jsonDecode(request.body) as Map<String, dynamic>;
    expect(body['data'], isNull);
    expect(body['fecha_operacion'], '2026-10-03');
    expect(body['peso_total_kg'], '10.125');
    expect(body['precio_por_kg'], '1000.123456');
    expect(body['monto_total'], '10126.24');
    expect(body['animal_ids'], hasLength(2));
    final initialPayment = body['cobro_inicial'] as Map<String, dynamic>;
    expect(initialPayment['monto'], '5000.10');
    expect(initialPayment['medio_cobro'], 'transferencia');
  });

  test('envia null como cobro inicial de una venta pendiente', () async {
    late Request request;
    final provider = _provider((captured) {
      request = captured;
      return _successResponse(captured);
    });
    final timestamp = DateTime.utc(2026, 10, 3, 18, 30);

    await provider.upsert<BrickLivestockSaleModel>(
      BrickLivestockSaleModel(
        localId: '74d4202e-99e3-431d-826c-ac1e8e366187',
        establishmentId: '5d035241-a780-48f1-a259-fd8eea7025b1',
        operationDate: DateTime(2026, 10, 3),
        buyerType: 'particular',
        buyerName: 'Juan',
        buyerLastName: 'Perez',
        isCompany: false,
        dteNumber: '001234567-9',
        saleType: 'al_bulto',
        totalAmount: '10000.00',
        animalIdsJson: jsonEncode([
          '2e4ffc88-aa9d-4b4c-a5e2-d45013cf7346',
        ]),
        paymentCondition: 'pendiente',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    final body = jsonDecode(request.body) as Map<String, dynamic>;
    expect(body['peso_total_kg'], isNull);
    expect(body['precio_por_kg'], isNull);
    expect(body['cobro_inicial'], isNull);
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
