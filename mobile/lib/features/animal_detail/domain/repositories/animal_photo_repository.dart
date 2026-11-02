import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';

/// Contrato para leer la foto local opcional de un animal.
abstract class AnimalPhotoRepository {
  /// Obtiene la foto sin exponer su ubicacion fisica.
  Future<Result<AnimalPhoto?>> getPhoto({
    required String establishmentId,
    required String animalId,
  });
}
