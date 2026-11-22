import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_location.dart';

/// Observa la ubicación persistida del animal sin recargar la ficha completa.
abstract interface class AnimalLocationRepository {
  /// Emite la ubicación inicial y sus cambios; `null` si el animal no está
  /// disponible en [establishmentId]. No consulta red.
  Stream<Result<AnimalLocation?>> watchLocation(String animalId, {required String establishmentId});
}
