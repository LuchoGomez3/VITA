import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/mappers/operating_expense_brick_mapper.dart';

void main() {
  test('serializa centavos sin usar double', () {
    expect(OperatingExpenseBrickMapper.amountToDecimal(15000000), '150000.00');
    expect(OperatingExpenseBrickMapper.amountToDecimal(4500001), '45000.01');
  });

  test('recupera exactamente los centavos del decimal backend', () {
    expect(OperatingExpenseBrickMapper.decimalToCents('150000.00'), 15000000);
    expect(OperatingExpenseBrickMapper.decimalToCents('45000.01'), 4500001);
  });
}
