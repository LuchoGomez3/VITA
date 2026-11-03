import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

/// Mensaje para el productor cuando falla una lectura del GPS.
///
/// Lo comparten el paso 3 (punto de referencia) y el paso 4 (marcar un
/// vértice recorriendo el campo).
String locationFailureMessage(DomainException error) {
  return switch (error.reason) {
    CurrentLocationFailure.serviceDisabled => EstablishmentRegisterStrings.stepThreeLocationServiceDisabledError,
    CurrentLocationFailure.permissionDenied => EstablishmentRegisterStrings.stepThreeLocationPermissionDeniedError,
    CurrentLocationFailure.permissionDeniedForever =>
      EstablishmentRegisterStrings.stepThreeLocationPermissionDeniedForeverError,
    CurrentLocationFailure.timeout => EstablishmentRegisterStrings.stepThreeLocationTimeoutError,
    _ => EstablishmentRegisterStrings.stepThreeLocationUnknownError,
  };
}
