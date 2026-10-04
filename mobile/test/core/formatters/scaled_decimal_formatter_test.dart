import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/formatters/scaled_decimal_formatter.dart';

void main() {
  test('formatea y parsea seis decimales sin usar punto flotante', () {
    expect(ScaledDecimalFormatter.format(1000123456, 6), '1000.123456');
    expect(ScaledDecimalFormatter.parse('1000.123456', 6), 1000123456);
  });

  test('completa decimales faltantes sin cambiar el valor', () {
    expect(ScaledDecimalFormatter.parse('10,125', 3), 10125);
    expect(ScaledDecimalFormatter.format(10125, 3), '10.125');
  });

  test('rechaza precision excedente en lugar de truncarla', () {
    expect(
      () => ScaledDecimalFormatter.parse('1000.1234567', 6),
      throwsFormatException,
    );
  });
}
