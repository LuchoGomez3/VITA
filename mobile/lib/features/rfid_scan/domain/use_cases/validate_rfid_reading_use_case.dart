import 'package:frontend_mayoral/core/identification/rfid_tag_validator.dart';

/// Valida el formato de una lectura de caravana electronica.
class ValidateRfidReadingUseCase {
  /// Crea el caso de uso reutilizando la regla comun de caravanas RFID.
  const ValidateRfidReadingUseCase({
    RfidTagValidator validator = const RfidTagValidator(),
  }) : _validator = validator;

  final RfidTagValidator _validator;

  /// Devuelve `true` solo para valores de exactamente 15 digitos numericos.
  bool call(String reading) => _validator(reading);
}
