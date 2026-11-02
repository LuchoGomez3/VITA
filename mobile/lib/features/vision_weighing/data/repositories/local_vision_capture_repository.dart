import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/services/capture_quality_analyzer.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_capture_repository.dart';

/// Ejecuta codecs y análisis en un isolate para mantener la UI fluida en móvil.
class LocalVisionCaptureRepository implements VisionCaptureRepository {
  /// No necesita red, permisos adicionales ni un modelo de estimación de peso.
  const LocalVisionCaptureRepository();

  @override
  Future<VisionCapture> prepare(Uint8List bytes) async {
    try {
      return await compute(analyzeCapture, bytes);
    } on Exception catch (error) {
      throw VisionDeviceException(cause: error);
    }
  }
}
