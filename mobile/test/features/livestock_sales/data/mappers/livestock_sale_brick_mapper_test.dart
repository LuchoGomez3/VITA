import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/mappers/livestock_sale_brick_mapper.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';

void main() {
  test('conserva precio, peso y cobro exactos en ida y vuelta Brick', () {
    final timestamp = DateTime.utc(2026, 10, 3, 18, 30);
    final sale = LivestockSale(
      id: 'sale-id',
      establishmentId: 'establishment-id',
      operationDate: DateTime(2026, 10, 3),
      buyerType: LivestockSaleBuyerType.slaughterhouse,
      buyerName: 'Comprador SA',
      isCompany: true,
      dteNumber: '001234567-9',
      saleType: LivestockSaleType.perKilogram,
      totalWeightGrams: 10125,
      pricePerKgMicros: 1000123456,
      totalAmountCents: 1012624,
      animalIds: const ['animal-a', 'animal-b'],
      paymentCondition: LivestockSalePaymentCondition.partial,
      initialPayment: LivestockSaleInitialPayment(
        id: 'payment-id',
        date: DateTime(2026, 10, 3),
        amountCents: 500010,
        method: LivestockSalePaymentMethod.card,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      createdAt: timestamp,
      updatedAt: timestamp,
      syncStatus: LivestockSaleSyncStatus.pending,
    );

    final brick = LivestockSaleBrickMapper.toBrick(sale);
    expect(brick.totalWeightKg, '10.125');
    expect(brick.pricePerKg, '1000.123456');
    expect(brick.totalAmount, '10126.24');
    final payment = jsonDecode(brick.initialPaymentJson!) as Map<String, dynamic>;
    expect(payment['monto'], '5000.10');
    expect(payment['medio_cobro'], 'tarjeta');

    final restored = LivestockSaleBrickMapper.fromBrick(brick);
    expect(restored, sale);
  });
}
