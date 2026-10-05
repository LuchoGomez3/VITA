import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';

/// Expone la orientación física desde un contrato independiente del sensor.
class WatchVisionCameraOrientation {
  /// Recibe el puerto que transforma eventos del acelerómetro.
  const WatchVisionCameraOrientation(this._repository);

  final VisionCameraRepository _repository;

  /// Devuelve el flujo de orientaciones estabilizadas por la implementación.
  Stream<VisionDeviceOrientation> call() => _repository.orientationChanges;
}
