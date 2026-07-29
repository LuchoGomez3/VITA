import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';

/// Repositorio mock que simula un alta exitosa e instantánea.
///
// TODO(lucho): Reemplazar por la implementación real contra el backend en la
// Etapa 3 de "registrar establecimiento" (ver .claude/specs/registrar-establecimiento.md).
class EstablishmentRegistrationMockRepository implements EstablishmentRegistrationRepository {
  @override
  Future<Result<RegisteredEstablishment>> register(
    EstablishmentRegistration registration,
  ) async {
    return Result.success(
      RegisteredEstablishment(
        id: 'mock-${registration.nroRenspa}',
        registration: registration,
        createdAt: DateTime.now(),
      ),
    );
  }
}
