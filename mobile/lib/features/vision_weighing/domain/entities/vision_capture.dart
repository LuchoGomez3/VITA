import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'vision_capture.freezed.dart';

/// Resultado técnico de los controles locales; no reconoce animales.
enum CaptureQuality {
  /// Sin advertencias técnicas; el perfil requiere revisión del operario.
  reviewRequired,

  /// Imagen sin detalle suficiente en la zona central.
  blurry,

  /// Reservado para un futuro detector de encuadre, no para dimensiones JPEG.
  poorlyFramed,

  /// Resolución insuficiente para preparar una futura inferencia local.
  insufficientResolution,

  /// Fotografía demasiado oscura o sobreexpuesta.
  badExposure,
}

/// Foto orientada para revisión junto con la predicción local, si existe.
@freezed
sealed class VisionCapture with _$VisionCapture {
  /// Conserva JPEG normalizado y diagnóstico de calidad.
  const factory VisionCapture({
    required Uint8List jpegBytes,
    required CaptureQuality quality,
    required double sharpness,
    double? estimatedWeightKg,

    /// Límites del intervalo empírico; no son confianza de una foto individual.
    double? estimatedWeightLowerKg,
    double? estimatedWeightUpperKg,
    double? intervalTargetCoverage,
  }) = _VisionCapture;
}
