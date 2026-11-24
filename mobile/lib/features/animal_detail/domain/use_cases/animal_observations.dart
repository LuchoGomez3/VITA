import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';

/// Nota independiente del texto histórico del animal.
typedef AnimalObservation = ({String text, DateTime date, AnimalSyncStatus status});

/// Acceso al historial y registro local de notas de una ficha.
abstract interface class AnimalObservationRepository {
  /// Emite el historial vigente, incluso sin conexión.
  Stream<List<AnimalObservation>> watch(String establishmentId, String animalId);

  /// Guarda una nueva nota vinculada al animal.
  Future<void> add(String establishmentId, String animalId, String text);
}

/// Consulta y agrega notas independientes del animal.
class AnimalObservations {
  /// Recibe el contrato de persistencia local.
  const AnimalObservations(this._repository);

  final AnimalObservationRepository _repository;

  /// Observa el historial del animal.
  Stream<List<AnimalObservation>> watch(String establishmentId, String animalId) =>
      _repository.watch(establishmentId, animalId);

  /// Guarda una nota si tiene texto.
  Future<void> add(String establishmentId, String animalId, String text) async {
    if (text.trim().isEmpty) return;
    await _repository.add(establishmentId, animalId, text.trim());
  }
}
