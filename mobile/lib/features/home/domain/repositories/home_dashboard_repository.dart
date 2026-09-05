import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';

/// Contrato para obtener los indicadores productivos de Inicio.
abstract class HomeDashboardRepository {
  /// Devuelve las membresias disponibles en el catalogo offline.
  Future<Result<Map<String, EstablishmentMembership>>> getEstablishments();

  /// Calcula el tablero con la informacion local disponible.
  Future<Result<HomeDashboard>> getDashboard({
    Set<String>? establishmentIds,
  });
}
