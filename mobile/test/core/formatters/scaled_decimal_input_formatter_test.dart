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

  test('agrupa miles sin cambiar la precision decimal', () {
    final formatter = ScaledDecimalInputFormatter(
      scale: 6,
      groupThousands: true,
    );

    expect(_format(formatter, '100', '1000').text, '1.000');
    expect(_format(formatter, '1.000', '1.0000').text, '10.000');
    expect(_format(formatter, '10.000', '10.000,').text, '10.000,');
    expect(_format(formatter, '10.000,', '10.000,123456').text, '10.000,123456');
    expect(
      ScaledDecimalInputFormatter.normalizeGrouped('10.000,123456'),
      '10000.123456',
    );
  });

  test('interpreta importes pegados con puntos como miles', () {
    final pricePerKilogram = ScaledDecimalInputFormatter(
      scale: 6,
      groupThousands: true,
    );
    final totalAmount = ScaledDecimalInputFormatter(
      scale: 2,
      groupThousands: true,
    );

    expect(_format(pricePerKilogram, '', '1.000').text, '1.000');
    expect(_format(totalAmount, '', '1.000').text, '1.000');
    expect(
      ScaledDecimalInputFormatter.normalizeGrouped(
        _format(pricePerKilogram, '', '1.000').text,
      ),
      '1000',
    );
  });

  test('conserva el punto decimal cuando el texto no agrupa miles', () {
    final formatter = ScaledDecimalInputFormatter(
      scale: 2,
      groupThousands: true,
    );

    expect(_format(formatter, '', '1000.25').text, '1.000,25');
  });

  test('formatea valores canonicos recuperados de un borrador', () {
    expect(
      ScaledDecimalInputFormatter.formatGroupedCanonical(
        '1000.123456',
        scale: 6,
      ),
      '1.000,123456',
    );
    expect(
      ScaledDecimalInputFormatter.formatGroupedCanonical(
        '1.000',
        scale: 6,
      ),
      '1,000',
    );
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
