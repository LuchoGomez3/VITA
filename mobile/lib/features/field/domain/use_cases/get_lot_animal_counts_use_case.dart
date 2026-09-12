import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_repository.dart';

/// Calcula los conteos locales por UUID de lote.
class GetLotAnimalCountsUseCase {
  /// Crea el caso de uso con su fuente offline.
  const GetLotAnimalCountsUseCase(this._repository);

  final LotAnimalRepository _repository;

  /// Devuelve cero implícito para cualquier lote ausente del mapa.
  Future<Result<Map<String, int>>> call(String establishmentId) async {
    final result = await _repository.getAnimals(
      establishmentId: establishmentId,
    );
    if (result case Success<List<LotAnimalSummary>>(:final data)) {
      return Result.success(_countByLot(data));
    }
    if (result case Failure<List<LotAnimalSummary>>(:final error)) {
      return Result.failure(error);
    }
    throw StateError('Unsupported animal count result.');
  }

  Map<String, int> _countByLot(List<LotAnimalSummary> animals) {
    final counts = <String, int>{};
    for (final animal in animals) {
      counts.update(animal.lotId, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }
}
