import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_change.dart';

/// Contrato de lectura y edición para la ficha de animal.
abstract class AnimalDetailRepository {
  /// Obtiene la ficha; refreshRemote false valida ediciones solo con datos locales.
  Future<Result<AnimalDetail>> getById(String animalId, {bool refreshRemote = true});

  /// Guarda una edición primero en el dispositivo y devuelve la ficha actualizada.
  Future<Result<AnimalDetail>> applyChange(String animalId, AnimalDetailChange change);

  /// Vuelve a encolar la sincronización de un animal rechazado.
  Future<Result<void>> retrySync(String animalId);
}
