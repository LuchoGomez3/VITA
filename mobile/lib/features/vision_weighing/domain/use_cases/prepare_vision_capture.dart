import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_capture_repository.dart';

/// Coordina el control obligatorio previo a revisar una captura lateral.
class PrepareVisionCapture {
  /// Recibe el contrato de procesamiento local.
  const PrepareVisionCapture(this._repository);

  final VisionCaptureRepository _repository;

  /// No habilita inferencia: una foto nítida todavía requiere revisar el perfil.
  Future<VisionCapture> call(Uint8List bytes) => _repository.prepare(bytes);
}
