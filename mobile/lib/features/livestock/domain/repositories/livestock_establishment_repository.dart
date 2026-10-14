import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';

/// Expone los establecimientos disponibles para las acciones de Hacienda.
abstract class LivestockEstablishmentRepository {
  /// Recupera las membresias almacenadas en el catalogo offline.
  Future<Result<List<EstablishmentMembership>>> getEstablishments();
}
