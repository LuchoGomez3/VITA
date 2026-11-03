import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_parent.dart';

/// Fuente local de animales para la selección de progenitores.
abstract class AnimalParentRepository {
  /// Lee los animales no eliminados del establecimiento seleccionado.
  Future<Result<List<AnimalParent>>> getParents(String establishmentId);
}
