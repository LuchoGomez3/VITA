import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_camera_info.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';

/// Inicializa la cámara trasera sin exponer el plugin a Presentation.
class InitializeVisionCamera {
  /// Recibe el puerto de cámara compartido por la sesión.
  const InitializeVisionCamera(this._repository);

  final VisionCameraRepository _repository;

  /// Abre la cámara y devuelve sus metadatos visuales.
  Future<VisionCameraInfo> call() => _repository.initialize();
}
