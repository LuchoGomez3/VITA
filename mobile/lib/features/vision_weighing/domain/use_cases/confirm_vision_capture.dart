import 'package:frontend_mayoral/features/vision_weighing/domain/entities/reviewed_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';

/// Valida los controles humanos y transforma la captura en un dato guardable.
class ConfirmVisionCapture {
  /// Crea el caso de uso sin dependencias externas.
  const ConfirmVisionCapture();

  /// Exige nitidez, animal completo, perfil lateral y calibración válida.
  ReviewedVisionCapture call({
    required VisionCapture capture,
    required bool sharpnessConfirmed,
    required bool completeAnimalConfirmed,
    required bool lateralConfirmed,
    double? calibrationWeightKg,
  }) {
    if (!sharpnessConfirmed ||
        !completeAnimalConfirmed ||
        !lateralConfirmed ||
        (calibrationWeightKg != null && (!calibrationWeightKg.isFinite || calibrationWeightKg <= 0))) {
      throw const InvalidVisionCaptureReviewException();
    }
    return ReviewedVisionCapture(capture: capture, calibrationWeightKg: calibrationWeightKg);
  }
}
