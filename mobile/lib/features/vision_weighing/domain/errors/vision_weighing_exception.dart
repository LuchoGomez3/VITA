import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';

/// Errores esperables del flujo de pesaje que atraviesan las capas sin cadenas mágicas.
sealed class VisionWeighingException implements Exception {
  /// Conserva opcionalmente la causa técnica para diagnóstico interno.
  const VisionWeighingException({this.cause});

  /// Error original producido por infraestructura o validación.
  final Object? cause;
}

/// La captura no cumple una condición que impide ejecutar el modelo.
final class VisionCaptureRejectedException extends VisionWeighingException {
  /// Identifica el diagnóstico que provocó el rechazo.
  const VisionCaptureRejectedException(this.quality);

  /// Calidad técnica detectada durante el preprocesamiento.
  final CaptureQuality quality;
}

/// El modelo o su calibración devolvieron un resultado inválido.
final class InvalidVisionWeightEstimateException extends VisionWeighingException {
  /// Crea el error de validación de inferencia.
  const InvalidVisionWeightEstimateException({super.cause});
}

/// Faltan controles humanos o el peso de calibración es inválido.
final class InvalidVisionCaptureReviewException extends VisionWeighingException {
  /// Crea el error de revisión manual.
  const InvalidVisionCaptureReviewException();
}

/// El pesaje no puede vincularse con los datos recibidos.
final class InvalidVisionWeightSaveException extends VisionWeighingException {
  /// Crea el error de validación previo a persistir.
  const InvalidVisionWeightSaveException();
}

/// El animal elegido dejó de existir en el almacenamiento local.
final class VisionAnimalNotFoundException extends VisionWeighingException {
  /// Crea el error de identidad ausente.
  const VisionAnimalNotFoundException();
}

/// Falló una integración local de cámara, galería, codecs o modelo.
final class VisionDeviceException extends VisionWeighingException {
  /// Envuelve el error técnico conservando una excepción tipada hacia arriba.
  const VisionDeviceException({super.cause});
}
