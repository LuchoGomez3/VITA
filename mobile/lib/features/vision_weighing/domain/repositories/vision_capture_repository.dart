import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';

/// Contrato para preparar fotografías sin depender de cámara ni codecs.
abstract interface class VisionCaptureRepository {
  /// Normaliza la orientación y evalúa calidad antes de cualquier inferencia.
  Future<VisionCapture> prepare(Uint8List bytes);
}
