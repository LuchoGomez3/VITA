import 'package:frontend_mayoral/core/validators/rfid_validator.dart';

/// Valida el formato de una lectura de caravana electronica.
class ValidateRfidReadingUseCase {
  /// Devuelve `true` solo para valores de exactamente 15 digitos numericos.
  bool call(String reading) => RfidValidator.isValid(reading);
}
