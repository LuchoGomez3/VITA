import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';

/// Obtiene los establecimientos disponibles para filtrar el tablero.
class GetHomeEstablishmentsUseCase {
  /// Crea el caso de uso con el contrato de datos de Inicio.
  const GetHomeEstablishmentsUseCase(this._repository);

  final HomeDashboardRepository _repository;

  /// Devuelve un mapa estable de ID y membresia por establecimiento.
  Future<Result<Map<String, EstablishmentMembership>>> call() {
    return _repository.getEstablishments();
  }
}
