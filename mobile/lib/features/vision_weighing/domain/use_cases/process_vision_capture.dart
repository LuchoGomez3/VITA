import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/estimate_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';

/// Ejecuta preparación e inferencia aplicando la política de rechazo previa.
class ProcessVisionCapture {
  /// Recibe operaciones independientes para poder probar el flujo sin plugins.
  const ProcessVisionCapture(this._prepare, this._estimate);

  final PrepareVisionCapture _prepare;
  final EstimateVisionWeight _estimate;

  /// Interrumpe el modelo cuando la resolución no permite una entrada válida.
  Future<VisionCapture> call(Uint8List bytes) async {
    final capture = await _prepare(bytes);
    if (capture.quality == CaptureQuality.insufficientResolution) {
      throw VisionCaptureRejectedException(capture.quality);
    }
    final estimate = await _estimate(capture.jpegBytes);
    return capture.copyWith(
      estimatedWeightKg: estimate.weightKg,
      estimatedWeightLowerKg: estimate.lowerKg,
      estimatedWeightUpperKg: estimate.upperKg,
      intervalTargetCoverage: estimate.targetCoverage,
    );
  }
}
