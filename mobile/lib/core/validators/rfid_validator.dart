/// Motivo compartido de validación, sin texto de presentación.
enum RfidValidationFailure {
  /// Un RFID completo debe tener exactamente quince dígitos ASCII.
  invalidFormat,
}

/// Regla única de formato para el ingreso manual y la lectura de RFID.
abstract final class RfidValidator {
  /// Longitud del identificador completo.
  static const length = 15;

  static final _nonDigit = RegExp('[^0-9]');

  /// Permite confirmar únicamente un RFID completo, sin normalizar caracteres.
  static bool isValid(String value) => value.length == length && !_nonDigit.hasMatch(value);

  /// Permite el borrador vacío o parcial mientras se escribe.
  static bool isEditable(String value) => value.length <= length && !_nonDigit.hasMatch(value);
}
