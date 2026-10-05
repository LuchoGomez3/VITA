import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';

part 'animal_detail_change.freezed.dart';

/// Una intención de edición; cada variante modifica solo su dato de negocio.
@freezed
sealed class AnimalDetailChange with _$AnimalDetailChange {
  /// Registra una nueva pesada manual con su fecha, sin modificar la inicial.
  const factory AnimalDetailChange.weight({required double weightKg, required DateTime date}) = RecordAnimalWeight;

  /// Asigna una categoría seleccionada del catálogo compatible.
  const factory AnimalDetailChange.category({required String categoryId}) = ChangeAnimalCategory;

  /// Cambia la condición de una hembra; null limpia una condición no aplicable.
  const factory AnimalDetailChange.reproduction({required AnimalReproductiveStatus? status}) = ChangeAnimalReproduction;

  /// Baja por muerte; no borra el animal ni su historial.
  const factory AnimalDetailChange.death() = RecordAnimalDeath;

  /// Restaura el estado previo solo si la versión de la baja sigue vigente.
  const factory AnimalDetailChange.undoDeath({required AnimalStatus previousStatus, required DateTime deathUpdatedAt}) =
      UndoAnimalDeath;

  /// Agrega una entrada independiente, conservando las notas anteriores.
  const factory AnimalDetailChange.observation({required String text, required DateTime date}) = AddAnimalObservation;
}
