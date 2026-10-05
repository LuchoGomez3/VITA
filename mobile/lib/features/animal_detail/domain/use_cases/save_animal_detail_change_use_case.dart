import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_change.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';

/// Valida reglas de edición antes de que data guarde o encole una operación.
class SaveAnimalDetailChangeUseCase {
  /// Recibe el contrato de persistencia, sin depender de Brick ni de HTTP.
  const SaveAnimalDetailChangeUseCase(this._repository);

  final AnimalDetailRepository _repository;

  /// Consulta la versión vigente para no validar contra una ficha anterior.
  Future<Result<AnimalDetail>> call(String animalId, AnimalDetailChange change) async {
    final current = await _repository.getById(animalId, refreshRemote: false);
    if (current case Failure<AnimalDetail>()) return current;
    final detail = (current as Success<AnimalDetail>).data;
    final failure = validate(detail, change);
    if (failure != null) {
      return Result.failure(
        DomainException(message: 'Cambio inválido.', code: DomainErrorCode.validation, reason: failure),
      );
    }
    return _repository.applyChange(animalId, change);
  }

  /// Reglas puras compartidas por formulario y pruebas de negocio.
  static AnimalDetailEditFailure? validate(AnimalDetail detail, AnimalDetailChange change) {
    if (change is! UndoAnimalDeath && change is! AddAnimalObservation && detail.status != AnimalStatus.active) {
      return AnimalDetailEditFailure.inactiveAnimal;
    }
    return switch (change) {
      RecordAnimalWeight(:final weightKg) when !weightKg.isFinite || weightKg <= 0 =>
        AnimalDetailEditFailure.invalidWeight,
      AddAnimalObservation(:final text) when text.trim().isEmpty => AnimalDetailEditFailure.emptyObservation,
      ChangeAnimalCategory(:final categoryId) => _validateCategory(detail, categoryId),
      ChangeAnimalReproduction(:final status) => _validateReproduction(detail, status),
      UndoAnimalDeath(:final deathUpdatedAt)
          when detail.status != AnimalStatus.dead || detail.updatedAt != deathUpdatedAt =>
        AnimalDetailEditFailure.staleUndo,
      _ => null,
    };
  }

  static AnimalDetailEditFailure? _validateCategory(AnimalDetail detail, String categoryId) {
    final category = detail.categories.where((option) => option.id == categoryId).firstOrNull;
    if (category == null || (category.allowedSex != null && category.allowedSex != detail.sex)) {
      return AnimalDetailEditFailure.incompatibleCategory;
    }
    // Una categoría incompatible con la condición actual exige corregirla antes,
    // en lugar de borrar silenciosamente un diagnóstico de preñez conocido.
    if (!category.allowsReproductiveStatus &&
        (detail.reproductiveStatus == AnimalReproductiveStatus.empty ||
            detail.reproductiveStatus == AnimalReproductiveStatus.pregnant)) {
      return AnimalDetailEditFailure.reproductionNotAllowed;
    }
    return null;
  }

  static AnimalDetailEditFailure? _validateReproduction(AnimalDetail detail, AnimalReproductiveStatus? status) {
    if (detail.sex != AnimalSex.female) return AnimalDetailEditFailure.reproductionNotAllowed;
    if (status == null || status == AnimalReproductiveStatus.undetermined) return null;
    final category = detail.categories.where((option) => option.id == detail.categoryId).firstOrNull;
    return (category?.allowsReproductiveStatus ?? false) ? null : AnimalDetailEditFailure.reproductionNotAllowed;
  }
}
