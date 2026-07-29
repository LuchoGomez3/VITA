import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/formatters/renspa_input_formatter.dart';

void main() {
  group('RenspaInputFormatter.validationError', () {
    test('is incomplete when there are fewer than 13 digits', () {
      expect(
        RenspaInputFormatter.validationError('07.123.0.00456'),
        RenspaValidationError.incomplete,
      );
    });

    test('is null for a complete, correctly formatted RENSPA', () {
      expect(RenspaInputFormatter.validationError('07.123.0.00456/01'), isNull);
    });

    test('is incomplete for an empty value', () {
      expect(RenspaInputFormatter.validationError(''), RenspaValidationError.incomplete);
    });
  });

  group('RenspaInputFormatter.formatEditUpdate', () {
    late RenspaValidationError? reportedError;
    late RenspaInputFormatter formatter;

    setUp(() {
      reportedError = RenspaValidationError.incomplete;
      formatter = RenspaInputFormatter(
        onValidationChanged: (error) => reportedError = error,
      );
    });

    TextEditingValue valueFor(String text) => TextEditingValue(text: text);

    test('inserts separators as digits are typed', () {
      final result = formatter.formatEditUpdate(
        valueFor(''),
        valueFor('071230004560'),
      );

      expect(result.text, '07.123.0.00456/0');
      expect(reportedError, RenspaValidationError.incomplete);
    });

    test('reports null once the 13 digits are complete', () {
      final result = formatter.formatEditUpdate(
        valueFor('07.123.0.00456/0'),
        valueFor('07.123.0.00456/01'),
      );

      expect(result.text, '07.123.0.00456/01');
      expect(reportedError, isNull);
    });

    test('caps input at 13 digits', () {
      final result = formatter.formatEditUpdate(
        valueFor('07.123.0.00456/01'),
        valueFor('07.123.0.00456/019'),
      );

      expect(result.text, '07.123.0.00456/01');
      expect(reportedError, RenspaValidationError.maxLength);
    });

    test('reports invalid characters when a letter is typed', () {
      final result = formatter.formatEditUpdate(
        valueFor(''),
        valueFor('07a'),
      );

      expect(result.text, '07');
      expect(reportedError, RenspaValidationError.invalidCharacters);
    });
  });
}
