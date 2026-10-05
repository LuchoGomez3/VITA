import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_photo_picker_repository.dart';

/// Selecciona una fotografía local sin exponer `image_picker` a Presentation.
class PickVisionPhoto {
  /// Recibe el puerto implementado por la integración del dispositivo.
  const PickVisionPhoto(this._repository);

  final VisionPhotoPickerRepository _repository;

  /// Devuelve la foto o `null` cuando la selección fue cancelada.
  Future<Uint8List?> call() => _repository.pickPhoto();
}
