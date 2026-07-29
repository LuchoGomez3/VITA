import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';

/// Contrato de persistencia del alta de establecimiento.
abstract class EstablishmentRegistrationRepository {
  /// Registra un establecimiento nuevo.
  Future<Result<RegisteredEstablishment>> register(
    EstablishmentRegistration registration,
  );
}
