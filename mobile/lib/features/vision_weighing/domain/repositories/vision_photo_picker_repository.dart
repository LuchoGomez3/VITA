import 'dart:typed_data';

/// Contrato de selección de imágenes que mantiene `image_picker` fuera de UI.
abstract interface class VisionPhotoPickerRepository {
  /// Devuelve los bytes elegidos o `null` cuando el usuario cancela.
  Future<Uint8List?> pickPhoto();
}
