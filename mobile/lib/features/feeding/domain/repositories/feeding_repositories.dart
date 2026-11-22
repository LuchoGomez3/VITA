import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';

/// Historial de alimentación de un animal, armado sin conexión.
abstract class FeedingHistoryRepository {
  /// Cambios locales que requieren releer el historial.
  Stream<void> get changes;

  /// Pastoreo derivado más suplementos y dietas de [animalId].
  Future<Result<AnimalFeedingHistory>> getAnimalHistory(String animalId);
}

/// Datos y escritura del formulario "Registrar alimentación".
abstract class FeedingRegisterRepository {
  /// Animal por id, si sigue en stock.
  Future<Result<FeedingAnimal?>> getAnimal(String animalId);

  /// Animal por caravana (RFID de 15 dígitos o caravana visual).
  Future<Result<FeedingAnimal?>> findAnimalByTag(String tag, {required String establishmentId});

  /// Potreros vigentes del establecimiento.
  Future<Result<List<FeedingLot>>> getLots(String establishmentId);

  /// Catálogo de alimentos del establecimiento más los globales.
  Future<Result<List<Food>>> getFoods(String establishmentId);

  /// Guarda el registro y, si se creó en el formulario, el alimento nuevo.
  Future<Result<void>> saveRecord(FeedingRecord record, {Food? newFood});
}
