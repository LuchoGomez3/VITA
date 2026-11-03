import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';

/// Lee lo que hace falta para mover animales y ver su historial, siempre desde
/// lo guardado en el celular.
abstract interface class AnimalMovementRepository {
  /// Invalida las lecturas del historial cuando cambia su fuente local.
  /// No implica conectividad ni un resultado HTTP pendiente de persistencia.
  Stream<void> get historyChanges;

  /// El animal [animalId] si se puede mover; `null` si no está activo o no existe.
  Future<Result<MovementAnimal?>> getAnimal(String animalId);

  /// Busca por RFID o caravana visual únicamente en [establishmentId].
  /// El RFID exacto tiene prioridad. Las coincidencias ambiguas devuelven error.
  Future<Result<MovementAnimal?>> findAnimalByTag(String tag, {required String establishmentId});

  /// Potreros activos de [establishmentId] con cuántos animales tiene cada uno.
  Future<Result<List<MovementDestination>>> getDestinations(String establishmentId);

  /// Historial de potreros de [animalId], del más reciente al más viejo.
  /// La llegada actual se identifica con la ubicación local del animal, no
  /// con la primera fecha efectiva de la lista.
  Future<Result<List<MovementHistoryEntry>>> getHistory(String animalId);
}
