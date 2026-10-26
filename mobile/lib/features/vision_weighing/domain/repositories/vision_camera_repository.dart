import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_camera_info.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';

/// Contrato de cámara y orientación sin tipos pertenecientes a plugins.
abstract interface class VisionCameraRepository {
  /// Emite cambios estables de orientación física del dispositivo.
  Stream<VisionDeviceOrientation> get orientationChanges;

  /// Abre la cámara trasera y devuelve los datos necesarios para presentarla.
  Future<VisionCameraInfo> initialize();

  /// Captura y lee la fotografía actual completamente en memoria.
  Future<Uint8List> capturePhoto();

  /// Libera la cámara cuando la ruta pierde actividad o se cierra.
  Future<void> dispose();
}
