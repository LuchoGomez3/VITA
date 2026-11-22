import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_location.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_location_repository.dart';

/// Mantiene la ubicación de General alineada con la fuente local del historial.
class WatchAnimalLocationUseCase {
  /// Crea el caso de uso sobre el contrato de ubicación local.
  const WatchAnimalLocationUseCase(this._repository);

  final AnimalLocationRepository _repository;

  /// Observa el animal dentro del establecimiento que abrió la ficha.
  Stream<Result<AnimalLocation?>> call(String animalId, {required String establishmentId}) =>
      _repository.watchLocation(animalId, establishmentId: establishmentId);
}
