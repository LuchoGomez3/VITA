import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';

/// Libera los recursos nativos asociados con la cámara de esta sesión.
class DisposeVisionCamera {
  /// Recibe el puerto inicializado por la composición.
  const DisposeVisionCamera(this._repository);

  final VisionCameraRepository _repository;

  /// Cierra el controlador activo de manera serializada.
  Future<void> call() => _repository.dispose();
}
