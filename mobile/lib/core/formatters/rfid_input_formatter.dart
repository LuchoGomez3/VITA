import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/validators/rfid_validator.dart';

/// Admite hasta quince números y rechaza ediciones inválidas completas.
/// No convierte un pegado con letras o exceso de dígitos en otro RFID válido.
class RfidInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return RfidValidator.isEditable(newValue.text) ? newValue : oldValue;
  }
}
