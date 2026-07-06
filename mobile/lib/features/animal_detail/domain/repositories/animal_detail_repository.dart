import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';

/// Contrato de lectura offline-first para la ficha de animal.
abstract class AnimalDetailRepository {
  /// Obtiene el detalle por UUID local/backend.
  Future<Result<AnimalDetail>> getById(String animalId);
}
