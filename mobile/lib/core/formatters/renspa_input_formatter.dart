import 'package:flutter/services.dart';

/// Motivos de rechazo o estado incompleto de un numero de RENSPA.
enum RenspaValidationError {
  /// Todavia no se ingresaron los trece digitos.
  incomplete,

  /// La entrada contiene caracteres distintos de digitos, puntos o barra.
  invalidCharacters,

  /// La entrada supera los trece digitos.
  maxLength,
}

/// Aplica la mascara `NN.NNN.N.NNNNN/NN` y reporta su validacion local.
class RenspaInputFormatter extends TextInputFormatter {
  /// Crea el formateador con una notificacion por cada cambio.
  RenspaInputFormatter({required this.onValidationChanged});

  /// Recibe el estado detectado antes de normalizar la entrada.
  final ValueChanged<RenspaValidationError?> onValidationChanged;

  /// Cantidad exacta de digitos de un RENSPA.
  static const requiredDigits = 13;

  /// Devuelve el estado de un valor ya existente en el controlador.
  static RenspaValidationError? validationError(String value) {
    final digits = _digitsOnly(value);
    if (digits.length != requiredDigits) {
      return RenspaValidationError.incomplete;
    }
    return null;
  }

  static String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String _formatDigits(String digits) {
    final length = digits.length;
    if (length <= 2) {
      return digits;
    }
    if (length <= 5) {
      return '${digits.substring(0, 2)}.${digits.substring(2)}';
    }
    if (length <= 6) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5)}';
    }
    if (length <= 11) {
      return '${digits.substring(0, 2)}.'
          '${digits.substring(2, 5)}.'
          '${digits.substring(5, 6)}.'
          '${digits.substring(6)}';
    }
    return '${digits.substring(0, 2)}.'
        '${digits.substring(2, 5)}.'
        '${digits.substring(5, 6)}.'
        '${digits.substring(6, 11)}/'
        '${digits.substring(11)}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final allDigits = _digitsOnly(newValue.text);
    final hasInvalidCharacters = RegExp(r'[^\d.\/]').hasMatch(newValue.text);
    final exceedsMaxLength = allDigits.length > requiredDigits;
    final acceptedLength = exceedsMaxLength ? requiredDigits : allDigits.length;
    final formattedValue = _formatDigits(
      allDigits.substring(0, acceptedLength),
    );
    final storedValidation = validationError(formattedValue);

    onValidationChanged(
      hasInvalidCharacters
          ? RenspaValidationError.invalidCharacters
          : exceedsMaxLength
          ? RenspaValidationError.maxLength
          : storedValidation,
    );

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
