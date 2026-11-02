import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';

/// Captura una fotografía mediante la sesión de cámara inicializada.
class CaptureVisionPhoto {
  /// Recibe el mismo puerto utilizado durante la inicialización.
  const CaptureVisionPhoto(this._repository);

  final VisionCameraRepository _repository;

  /// Devuelve los bytes JPEG leídos desde el almacenamiento temporal del plugin.
  Future<Uint8List> call(VisionDeviceOrientation orientation) => _repository.capturePhoto(orientation: orientation);
}
