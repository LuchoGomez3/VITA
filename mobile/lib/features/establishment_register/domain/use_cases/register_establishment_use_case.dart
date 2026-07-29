import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';

/// Caso de uso para registrar un establecimiento.
class RegisterEstablishmentUseCase {
  /// Crea el caso de uso con el repositorio inyectado.
  const RegisterEstablishmentUseCase(this._repository);

  final EstablishmentRegistrationRepository _repository;

  /// Ejecuta el registro delegando en el repositorio.
  Future<Result<RegisteredEstablishment>> call(
    EstablishmentRegistration registration,
  ) {
    return _repository.register(registration);
  }
}
