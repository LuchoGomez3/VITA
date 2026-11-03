import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';
import 'package:logging/logging.dart';

/// Adapta el catálogo local compartido al dominio de Hacienda.
class LivestockEstablishmentRepositoryImpl implements LivestockEstablishmentRepository {
  /// Crea el repositorio sobre el catálogo sincronizado durante el login.
  const LivestockEstablishmentRepositoryImpl({
    required EstablishmentCatalog establishmentCatalog,
  }) : _establishmentCatalog = establishmentCatalog;

  static final Logger _logger = Logger('LivestockEstablishmentRepository');
  final EstablishmentCatalog _establishmentCatalog;

  @override
  Future<Result<List<LivestockEstablishment>>> getEstablishments() async {
    try {
      final memberships = await _establishmentCatalog.getMemberships();
      return Result.success(
        memberships
            .map(
              (membership) => LivestockEstablishment(
                id: membership.id,
                name: membership.name,
                role: membership.role,
              ),
            )
            .toList(growable: false),
      );
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'No se pudo leer el catálogo offline para Hacienda.',
        error,
        stackTrace,
      );
      return const Result.failure(
        DomainException(
          message: 'No se pudieron cargar los establecimientos.',
        ),
      );
    }
  }
}
