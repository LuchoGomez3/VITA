import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

/// Puente visual del plugin; el repositorio conserva la propiedad del recurso.
/// La composición conecta sus notificaciones sin exponerlo al dominio.
class VisionCameraPreviewAdapter {
  /// Recibe el controlador listo o su retiro antes del cierre nativo.
  CameraController? controller;

  /// Construye únicamente el preview del controlador vigente.
  Widget buildPreview(BuildContext context) {
    final activeController = controller;
    return activeController == null || !activeController.value.isInitialized
        ? const SizedBox.shrink()
        : CameraPreview(activeController);
  }
}
