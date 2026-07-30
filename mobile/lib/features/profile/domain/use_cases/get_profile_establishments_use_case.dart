import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/domain/repositories/profile_repository.dart';

/// Obtiene los establecimientos disponibles para mostrarlos en Perfil.
class GetProfileEstablishmentsUseCase {
  /// Crea el caso de uso con el repositorio de Perfil.
  const GetProfileEstablishmentsUseCase(this._repository);

  final ProfileRepository _repository;

  /// Devuelve el catálogo completo guardado durante el login.
  Future<Result<List<EstablishmentDetails>>> call() {
    return _repository.getEstablishments();
  }
}
