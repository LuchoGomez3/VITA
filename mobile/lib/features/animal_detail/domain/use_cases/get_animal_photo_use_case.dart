import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_photo_repository.dart';

/// Obtiene la foto local opcional de un animal.
class GetAnimalPhotoUseCase {
  /// Crea el caso de uso con el repositorio de fotos.
  const GetAnimalPhotoUseCase(this._repository);

  final AnimalPhotoRepository _repository;

  /// Lee la foto de [animalId] dentro de [establishmentId].
  Future<Result<AnimalPhoto?>> call({
    required String establishmentId,
    required String animalId,
  }) {
    return _repository.getPhoto(
      establishmentId: establishmentId,
      animalId: animalId,
    );
  }
}
