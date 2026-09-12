import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_repository.dart';
import 'package:logging/logging.dart';

/// Consulta la caché Brick de animales sin depender de otra feature.
class LotAnimalRepositoryImpl implements LotAnimalRepository {
  /// Crea la lectura local con el store compartido inyectado.
  const LotAnimalRepositoryImpl({required AnimalBrickStore store}) : _store = store;

  final AnimalBrickStore _store;
  static final _logger = Logger('LotAnimalRepository');

  @override
  Future<Result<List<LotAnimalSummary>>> getAnimals({
    required String establishmentId,
    String? lotId,
  }) async {
    try {
      final animals = await _store.getLocalAnimals();
      return Result.success([
        for (final animal in animals)
          if (animal.deletedAt == null &&
              animal.establishmentId == establishmentId &&
              (lotId == null || animal.lotId == lotId))
            LotAnimalSummary(
              id: animal.localId,
              establishmentId: animal.establishmentId,
              lotId: animal.lotId,
              rfidTagNumber: animal.rfidTagNumber,
              visualTag: animal.visualTag,
              categoryName: animal.categoryName,
            ),
      ]);
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudieron leer los animales del lote.', error, stackTrace);
      return const Result.failure(
        DomainException(
          message: 'No se pudieron leer los animales guardados.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }
}
