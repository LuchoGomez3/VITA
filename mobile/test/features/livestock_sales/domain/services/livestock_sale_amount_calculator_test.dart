import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/services/livestock_sale_amount_calculator.dart';

void main() {
  test('calcula con los seis decimales completos del precio', () {
    final total = LivestockSaleAmountCalculator.totalCents(
      totalWeightGrams: 10125,
      pricePerKgMicros: 1000123456,
    );

    expect(total, 1012624);
  });

  test('trunca hacia abajo el monto final incluso desde medio centavo', () {
    final total = LivestockSaleAmountCalculator.totalCents(
      totalWeightGrams: 1,
      pricePerKgMicros: 5000000,
    );

    expect(total, 0);
  });
}
