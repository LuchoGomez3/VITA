import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';

/// Lee lo que hace falta para mover animales y ver su historial, siempre desde
/// lo guardado en el celular.
abstract interface class AnimalMovementRepository {
  /// El animal [animalId] si se puede mover; `null` si no está activo o no existe.
  Future<Result<MovementAnimal?>> getAnimal(String animalId);

  /// Busca un animal activo por RFID (15 dígitos) o por caravana visual.
  Future<Result<MovementAnimal?>> findAnimalByTag(String tag);

  /// Potreros activos de [establishmentId] con cuántos animales tiene cada uno.
  Future<Result<List<MovementDestination>>> getDestinations(String establishmentId);

  /// Historial de potreros de [animalId], del más reciente al más viejo.
  Future<Result<List<MovementHistoryEntry>>> getHistory(String animalId);
}
