import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/formatters/rfid_input_formatter.dart';
import 'package:frontend_mayoral/core/validators/rfid_validator.dart';

void main() {
  final formatter = RfidInputFormatter();
  const valid = '982000412991416';

  test('acepta borradores numéricos hasta quince dígitos y conserva el cursor', () {
    for (final text in ['', '0', '98200041299141', valid]) {
      final value = TextEditingValue(text: text, selection: const TextSelection.collapsed(offset: 0));
      expect(formatter.formatEditUpdate(TextEditingValue.empty, value), value);
    }
    expect(RfidValidator.isValid(valid), isTrue);
    expect(RfidValidator.isValid('98200041299141'), isFalse);
  });

  for (final invalid in ['${valid}0', 'A$valid', '98200041299A416', '982 000412991416', '$valid\n', '١٢٣']) {
    test('rechaza la edición completa sin fabricar un RFID: $invalid', () {
      const old = TextEditingValue(text: '98', selection: TextSelection.collapsed(offset: 1));
      expect(formatter.formatEditUpdate(old, TextEditingValue(text: invalid)), same(old));
      expect(RfidValidator.isValid(invalid), isFalse);
    });
  }
}
