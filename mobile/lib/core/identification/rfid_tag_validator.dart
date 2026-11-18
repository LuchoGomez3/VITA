/// Valida el formato comun de una caravana electronica RFID.
class RfidTagValidator {
  /// Crea el validador compartido por todos los metodos de identificacion.
  const RfidTagValidator();

  static final RegExp _pattern = RegExp(r'^\d{15}$');

  /// Devuelve `true` solo para valores de exactamente 15 digitos numericos.
  bool call(String value) => _pattern.hasMatch(value);
}
