import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/formatters/cuit_input_formatter.dart';

void main() {
  test('keeps the cursor in place when deleting a middle digit', () {
    final formatter = CuitInputFormatter(onValidationChanged: (_) {});

    final result = formatter.formatEditUpdate(
      const TextEditingValue(
        text: '20-12345678-6',
        selection: TextSelection.collapsed(offset: 6),
      ),
      const TextEditingValue(
        text: '20-1245678-6',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );

    expect(result.text, '20-12456786');
    expect(result.selection, const TextSelection.collapsed(offset: 5));
  });
}
