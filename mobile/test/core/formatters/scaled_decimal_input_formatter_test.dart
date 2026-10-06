import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/formatters/scaled_decimal_input_formatter.dart';

void main() {
  test('acepta coma o punto hasta la precision configurada', () {
    final formatter = ScaledDecimalInputFormatter(scale: 3);

    expect(_format(formatter, '', '10,125').text, '10,125');
    expect(_format(formatter, '', '10.125').text, '10.125');
  });

  test('conserva el valor anterior ante caracteres o precision invalidos', () {
    final formatter = ScaledDecimalInputFormatter(scale: 2);

    expect(_format(formatter, '10,12', '10,123').text, '10,12');
    expect(_format(formatter, '10', '10a').text, '10');
  });
}

TextEditingValue _format(
  TextInputFormatter formatter,
  String oldText,
  String newText,
) {
  return formatter.formatEditUpdate(
    TextEditingValue(text: oldText),
    TextEditingValue(text: newText),
  );
}
