import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/reviewed_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';

part 'vision_capture_view_data.freezed.dart';

/// Estado visual de una captura separado de la entidad técnica de dominio.
@freezed
sealed class VisionCaptureViewData with _$VisionCaptureViewData {
  /// Conserva progreso de revisión, tiempo y persistencia de la pantalla.
  const factory VisionCaptureViewData({
    required VisionCapture capture,
    required int inferenceMilliseconds,
    ReviewedVisionCapture? reviewedCapture,
    @Default(ResultState<void>.initial()) ResultState<void> saveResult,
  }) = _VisionCaptureViewData;

  const VisionCaptureViewData._();

  /// Indica que los controles humanos ya produjeron una captura guardable.
  bool get confirmed => reviewedCapture != null;

  /// El guardado comparte una única fuente de progreso con la pantalla.
  bool get saving => saveResult is Loading<void>;

  /// Se confirma únicamente después de completar la persistencia local.
  bool get saved => saveResult is Data<void>;
}
