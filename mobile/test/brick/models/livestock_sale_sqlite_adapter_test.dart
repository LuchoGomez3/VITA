import 'dart:convert';

import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';

void main() {
  test('SQLite conserva el agregado y sus decimales exactos', () async {
    final provider = _FakeSqliteProvider();
    final adapter = BrickLivestockSaleModelAdapter();
    final timestamp = DateTime.utc(2026, 10, 3, 18, 30);
    final animalIds = jsonEncode([
      '2e4ffc88-aa9d-4b4c-a5e2-d45013cf7346',
      '0a29c84a-485c-4576-903b-f7556774ea19',
    ]);
    final initialPayment = jsonEncode({
      'id': '65510387-f31f-450c-b278-d4b254709549',
      'monto': '5000.10',
      'medio_cobro': 'tarjeta',
    });
    final sale = BrickLivestockSaleModel(
      localId: '74d4202e-99e3-431d-826c-ac1e8e366187',
      establishmentId: '5d035241-a780-48f1-a259-fd8eea7025b1',
      operationDate: DateTime(2026, 10, 3),
      buyerType: 'frigorifico',
      buyerName: 'Comprador de prueba SA',
      isCompany: true,
      dteNumber: '00123456789',
      saleType: 'por_kilo',
      totalWeightKg: '10.125',
      pricePerKg: '1000.123456',
      totalAmount: '10126.24',
      animalIdsJson: animalIds,
      paymentCondition: 'parcial',
      initialPaymentJson: initialPayment,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    final row = await adapter.toSqlite(sale, provider: provider);
    final restored = await adapter.fromSqlite(
      {...row, '_brick_id': 12},
      provider: provider,
    );

    expect(restored.primaryKey, 12);
    expect(restored.localId, sale.localId);
    expect(restored.pricePerKg, '1000.123456');
    expect(restored.totalWeightKg, '10.125');
    expect(restored.totalAmount, '10126.24');
    expect(restored.animalIdsJson, animalIds);
    expect(restored.initialPaymentJson, initialPayment);
    expect(restored.syncStatus, BrickLivestockSaleSyncStatus.pending);
  });
}

class _FakeSqliteProvider implements SqliteProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
