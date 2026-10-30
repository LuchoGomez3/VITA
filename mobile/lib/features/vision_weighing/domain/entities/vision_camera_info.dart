import 'package:freezed_annotation/freezed_annotation.dart';

part 'vision_camera_info.freezed.dart';

/// Metadatos de cámara que Presentation necesita para dibujar la vista previa.
@freezed
sealed class VisionCameraInfo with _$VisionCameraInfo {
  /// Describe la relación ancho/alto informada por el sensor activo.
  const factory VisionCameraInfo({required double aspectRatio}) = _VisionCameraInfo;
}
