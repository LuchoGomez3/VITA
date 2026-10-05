import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';

/// Lee las membresias de Hacienda desde el catalogo disponible sin conexion.
class LivestockEstablishmentRepositoryImpl implements LivestockEstablishmentRepository {
  /// Crea el repositorio con el lector compartido del catalogo local.
  const LivestockEstablishmentRepositoryImpl(this._catalog);

  final EstablishmentCatalog _catalog;

  @override
  Future<Result<List<EstablishmentMembership>>> getEstablishments() async {
    try {
      return Result.success(await _catalog.getMemberships());
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudieron leer los establecimientos disponibles.',
        ),
      );
    }
  }
}
