import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';

/// Consulta identidades locales para asociarlas a una foto en revisión.
abstract class VisionAnimalRepository {
  /// Lee los animales activos y los establecimientos accesibles sin red.
  Future<VisionAnimalOptions> getOptions();
}
