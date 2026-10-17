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
    final selection = _selectionAfterFormatting(
      source: newValue,
      formattedText: formattedValue,
    );

    onValidationChanged(
      hasInvalidCharacters
          ? CuitValidationError.invalidCharacters
          : exceedsMaxLength
          ? CuitValidationError.maxLength
          : storedValidation,
    );

    return TextEditingValue(
      text: formattedValue,
      selection: selection,
    );
  }

  TextSelection _selectionAfterFormatting({
    required TextEditingValue source,
    required String formattedText,
  }) {
    if (!source.selection.isValid) {
      return TextSelection.collapsed(offset: formattedText.length);
    }

    // La mascara agrega y quita guiones, por eso la posicion se conserva por
    // cantidad de digitos a la izquierda de cada extremo de la seleccion.
    return TextSelection(
      baseOffset: _formattedOffsetFor(
        source.text,
        source.selection.baseOffset,
        formattedText,
      ),
      extentOffset: _formattedOffsetFor(
        source.text,
        source.selection.extentOffset,
        formattedText,
      ),
      affinity: source.selection.affinity,
      isDirectional: source.selection.isDirectional,
    );
  }

  int _formattedOffsetFor(
    String sourceText,
    int sourceOffset,
    String formattedText,
  ) {
    final safeOffset = sourceOffset.clamp(0, sourceText.length);
    final digitsBeforeCursor = _digitsOnly(
      sourceText.substring(0, safeOffset),
    ).length;
    if (digitsBeforeCursor == 0) {
      return 0;
    }

    var seenDigits = 0;
    for (var index = 0; index < formattedText.length; index++) {
      if (RegExp(r'\d').hasMatch(formattedText[index])) {
        seenDigits++;
        if (seenDigits == digitsBeforeCursor) {
          return index + 1;
        }
      }
    }

    return formattedText.length;
  }
}
