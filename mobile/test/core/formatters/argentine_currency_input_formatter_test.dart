import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_form.dart';

void main() {
  const formatter = ArgentineCurrencyInputFormatter();

  test('separa los miles con puntos mientras se escribe', () {
    expect(_format(formatter, '150000'), '150.000');
    expect(_format(formatter, '1500000'), '1.500.000');
  });

  test('conserva hasta dos decimales separados por coma', () {
    expect(_format(formatter, '150000,5'), '150.000,5');
    expect(_format(formatter, '150000,567'), '150.000,56');
  });

  test('reformatea correctamente un importe pegado', () {
    expect(_format(formatter, r'$ 1.250.000,75'), '1.250.000,75');
  });

  test('convierte el texto formateado a centavos sin usar double', () {
    expect(parseArgentineCurrencyToCents('1.250.000,75'), 125000075);
  });
}

String _format(TextInputFormatter formatter, String value) {
  return formatter
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        ),
      )
      .text;
}
