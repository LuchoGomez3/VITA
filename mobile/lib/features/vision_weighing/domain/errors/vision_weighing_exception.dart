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

/// La membresía local no permite registrar pesajes en el establecimiento.
final class VisionWeighingAccessDeniedException extends VisionWeighingException {
  /// Deniega la escritura antes de guardar la foto o el pesaje.
  const VisionWeighingAccessDeniedException();
}

/// Falló una integración local de cámara, galería, codecs o modelo.
final class VisionDeviceException extends VisionWeighingException {
  /// Envuelve el error técnico conservando una excepción tipada hacia arriba.
  const VisionDeviceException({super.cause});
}

/// No hay un paquete de inferencia local utilizable en esta instalación.
final class VisionModelUnavailableException extends VisionWeighingException {
  /// Conserva el error de carga o contrato del modelo.
  const VisionModelUnavailableException({super.cause});
}

/// El sistema denegó o restringió el acceso a la cámara.
final class VisionCameraPermissionException extends VisionWeighingException {
  /// Indica si el usuario debe habilitar el acceso desde Ajustes.
  const VisionCameraPermissionException({this.requiresSettings = false, super.cause});

  /// iOS no vuelve a presentar el diálogo tras una denegación anterior.
  final bool requiresSettings;
}

/// El dispositivo no ofrece una cámara trasera compatible.
final class VisionCameraUnavailableException extends VisionWeighingException {
  /// Crea el diagnóstico de hardware ausente.
  const VisionCameraUnavailableException();
}
