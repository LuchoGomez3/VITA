import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';

/// Historial de potreros de un animal.
class GetAnimalMovementHistoryUseCase {
  /// Crea el caso de uso.
  const GetAnimalMovementHistoryUseCase(this._repository);

  final AnimalMovementRepository _repository;

  /// Devuelve el historial de [animalId].
  Future<Result<List<MovementHistoryEntry>>> call(String animalId) => _repository.getHistory(animalId);
}
