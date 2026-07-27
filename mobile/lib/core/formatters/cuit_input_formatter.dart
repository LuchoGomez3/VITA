import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/validators/validators.dart';

/// Motivos de rechazo o estado incompleto de un CUIT/CUIL.
enum CuitValidationError {
  /// Todavia no se ingresaron los once digitos.
  incomplete,

  /// La entrada contiene caracteres o guiones manuales invalidos.
  invalidCharacters,

  /// La entrada supera los once digitos.
  maxLength,

  /// El ultimo digito no coincide con el calculado mediante modulo 11.
  invalidCheckDigit,
}

/// Aplica la mascara `XX-XXXXXXXX-X` y reporta su validacion local.
class CuitInputFormatter extends TextInputFormatter {
  /// Crea el formateador con una notificacion por cada cambio.
  CuitInputFormatter({required this.onValidationChanged});

  /// Recibe el estado detectado antes de normalizar la entrada.
  final ValueChanged<CuitValidationError?> onValidationChanged;

  /// Cantidad exacta de digitos de un CUIT/CUIL.
  static const requiredDigits = 11;

  /// Devuelve el estado de un valor ya existente en el controlador.
  static CuitValidationError? validationError(String value) {
    final digits = _digitsOnly(value);
    if (digits.length != requiredDigits) {
      return CuitValidationError.incomplete;
    }
    return FormValidators.isCuitCheckDigitValid(digits) ? null : CuitValidationError.invalidCheckDigit;
  }

  static String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String _formatDigits(String digits) {
    if (digits.length <= 2) {
      return digits;
    }
    if (digits.length <= 10) {
      return '${digits.substring(0, 2)}-${digits.substring(2)}';
    }
    return '${digits.substring(0, 2)}-'
        '${digits.substring(2, 10)}-${digits.substring(10)}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final allDigits = _digitsOnly(newValue.text);
    final hasInvalidCharacters = RegExp(r'[^\d-]').hasMatch(newValue.text);
    final exceedsMaxLength = allDigits.length > requiredDigits;
    final acceptedLength = exceedsMaxLength ? requiredDigits : allDigits.length;
    final formattedValue = _formatDigits(
      allDigits.substring(0, acceptedLength),
    );
    final storedValidation = validationError(formattedValue);

    onValidationChanged(
      hasInvalidCharacters
          ? CuitValidationError.invalidCharacters
          : exceedsMaxLength
          ? CuitValidationError.maxLength
          : storedValidation,
    );

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
