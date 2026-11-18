import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/calculate_livestock_sale_amounts_use_case.dart';

void main() {
  const calculate = CalculateLivestockSaleAmountsUseCase();

  test('comparte la politica de cobro total, parcial y pendiente', () {
    for (final condition in LivestockSalePaymentCondition.values) {
      final amounts = calculate(
        saleType: LivestockSaleType.bulk,
        paymentCondition: condition,
        bulkTotalCents: 1000000,
        partialPaymentCents: 400000,
      );
      expect(amounts.totalCents, 1000000);
      switch (condition) {
        case LivestockSalePaymentCondition.total:
          expect(amounts.initialPaymentCents, 1000000);
          expect(amounts.pendingCents, 0);
        case LivestockSalePaymentCondition.partial:
          expect(amounts.initialPaymentCents, 400000);
          expect(amounts.pendingCents, 600000);
        case LivestockSalePaymentCondition.pending:
          expect(amounts.initialPaymentCents, isNull);
          expect(amounts.pendingCents, 1000000);
      }
    }
  });

  test('conserva el truncado por kilo y los seis decimales del precio', () {
    final amounts = calculate(
      saleType: LivestockSaleType.perKilogram,
      paymentCondition: LivestockSalePaymentCondition.partial,
      totalWeightGrams: 10125,
      pricePerKgMicros: 1000123456,
      partialPaymentCents: 400000,
    );
    expect(amounts.totalCents, 1012624);
    expect(amounts.pendingCents, 612624);
  });

  test('tolera entradas incompletas sin inventar un saldo', () {
    final missingTotal = calculate(
      saleType: LivestockSaleType.perKilogram,
      paymentCondition: LivestockSalePaymentCondition.total,
    );
    expect(missingTotal.totalCents, isNull);
    expect(missingTotal.initialPaymentCents, isNull);
    expect(missingTotal.pendingCents, isNull);
    final missingPayment = calculate(
      saleType: LivestockSaleType.bulk,
      paymentCondition: LivestockSalePaymentCondition.partial,
      bulkTotalCents: 1000,
    );
    expect(missingPayment.initialPaymentCents, isNull);
    expect(missingPayment.pendingCents, isNull);
  });

  test('no muestra un saldo negativo; conserva el importe para validar el error', () {
    final amounts = calculate(
      saleType: LivestockSaleType.bulk,
      paymentCondition: LivestockSalePaymentCondition.partial,
      bulkTotalCents: 1000,
      partialPaymentCents: 1100,
    );
    expect(amounts.initialPaymentCents, 1100);
    expect(amounts.pendingCents, isNull);
  });
}
