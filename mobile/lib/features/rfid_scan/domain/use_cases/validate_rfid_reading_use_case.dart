/// Valida el formato de una lectura de caravana electronica.
class ValidateRfidReadingUseCase {
  static final RegExp _rfidPattern = RegExp(r'^\d{15}$');

  /// Devuelve `true` solo para valores de exactamente 15 digitos numericos.
  bool call(String reading) => _rfidPattern.hasMatch(reading);
}
