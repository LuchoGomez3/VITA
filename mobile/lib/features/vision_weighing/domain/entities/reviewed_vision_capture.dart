import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';

part 'reviewed_vision_capture.freezed.dart';

/// Captura que superó los controles humanos requeridos para poder guardarse.
@freezed
sealed class ReviewedVisionCapture with _$ReviewedVisionCapture {
  /// Conserva la captura procesada y el peso real opcional de calibración.
  const factory ReviewedVisionCapture({
    required VisionCapture capture,
    double? calibrationWeightKg,
  }) = _ReviewedVisionCapture;
}
