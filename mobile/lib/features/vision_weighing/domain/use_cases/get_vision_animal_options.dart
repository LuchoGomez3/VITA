import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_animal_repository.dart';

/// Obtiene opciones locales para identificar el bovino fotografiado.
class GetVisionAnimalOptions {
  /// Recibe el puerto de consulta sin conocer Brick ni el lector RFID.
  const GetVisionAnimalOptions(this._repository);

  final VisionAnimalRepository _repository;

  /// Devuelve animales activos y establecimientos disponibles en el equipo.
  Future<VisionAnimalOptions> call() => _repository.getOptions();
}
