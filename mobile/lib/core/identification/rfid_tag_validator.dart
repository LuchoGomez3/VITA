import 'package:frontend_mayoral/core/validators/rfid_validator.dart';

/// Valida el formato comun de una caravana electronica RFID.
///
/// Delega en [RfidValidator] para que la venta, la lectura y el alta usen la
/// misma regla.
class RfidTagValidator {
  /// Crea el validador compartido por todos los metodos de identificacion.
  const RfidTagValidator();

  /// Devuelve `true` solo para valores de exactamente 15 digitos numericos.
  bool call(String value) => RfidValidator.isValid(value);
}
