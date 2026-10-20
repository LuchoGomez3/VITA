import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard_source.dart';

/// Contrato para obtener los indicadores productivos de Inicio.
abstract class HomeDashboardRepository {
  /// Devuelve las membresias disponibles en el catalogo offline.
  Future<Result<Map<String, EstablishmentMembership>>> getEstablishments();

  /// Lee y mapea la fotografia local usada por el calculo de dominio.
  Future<Result<HomeDashboardSource>> getDashboardSource({
    Set<String>? establishmentIds,
  });
}
