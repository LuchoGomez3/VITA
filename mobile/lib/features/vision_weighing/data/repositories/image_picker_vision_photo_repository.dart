import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_photo_picker_repository.dart';
import 'package:image_picker/image_picker.dart';

/// Implementa la selección de una foto mediante la galería del dispositivo.
class ImagePickerVisionPhotoRepository implements VisionPhotoPickerRepository {
  /// Permite reemplazar el plugin en pruebas de integración.
  ImagePickerVisionPhotoRepository({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pickPhoto() async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.gallery);
      return photo?.readAsBytes();
    } on Exception catch (error) {
      throw VisionDeviceException(cause: error);
    }
  }
}
