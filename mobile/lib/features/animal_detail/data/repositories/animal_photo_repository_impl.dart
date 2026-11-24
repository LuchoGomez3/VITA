import 'dart:io';

import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/animal_photo_store.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_photo_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/// Lee fotos privadas del dispositivo sin exponer rutas fisicas al dominio.
class AnimalPhotoRepositoryImpl implements AnimalPhotoRepository {
  /// Crea el repositorio sobre el almacenamiento local de fotos.
  const AnimalPhotoRepositoryImpl({required AnimalPhotoStore photoStore}) : _photoStore = photoStore;

  static final Logger _logger = Logger('AnimalPhotoRepository');
  final AnimalPhotoStore _photoStore;

  /// Toma una foto y la guarda en el mismo espacio privado que usa la ficha.
  Future<bool> takePhoto({required String establishmentId, required String animalId}) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1600, imageQuality: 85);
    if (image == null) return false;
    await _photoStore.savePhoto(establishmentId: establishmentId, animalId: animalId, sourcePath: image.path);
    return true;
  }

  @override
  Future<Result<AnimalPhoto?>> getPhoto({
    required String establishmentId,
    required String animalId,
  }) async {
    try {
      final bytes = await _photoStore.readPhotoBytes(
        establishmentId: establishmentId,
        animalId: animalId,
      );
      return Result.success(
        bytes == null ? null : AnimalPhoto.fromBytes(bytes),
      );
    } on FileSystemException catch (error) {
      return _photoUnavailable(error);
    } on MissingPlatformDirectoryException catch (error) {
      return _photoUnavailable(error);
    }
  }

  Result<AnimalPhoto?> _photoUnavailable(Object error) {
    _logger.warning(
      'No se pudo leer la foto local opcional del animal. '
      'Tipo: ${error.runtimeType}.',
    );
    return const Result.success(null);
  }
}
