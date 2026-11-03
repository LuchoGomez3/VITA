import 'package:flutter/widgets.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/capture_vision_photo.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/dispose_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/initialize_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/watch_vision_camera_orientation.dart';

/// Dependencias de cámara ensambladas fuera de Presentation.
class VisionCameraDependencies {
  /// Agrupa casos de uso y la superficie nativa requerida para la vista previa.
  const VisionCameraDependencies({
    required this.initialize,
    required this.capture,
    required this.watchOrientation,
    required this.dispose,
    required this.previewBuilder,
  });

  /// Inicializa el sensor trasero.
  final InitializeVisionCamera initialize;

  /// Captura la fotografía actual.
  final CaptureVisionPhoto capture;

  /// Observa la orientación física traducida a tipos de dominio.
  final WatchVisionCameraOrientation watchOrientation;

  /// Libera el controlador nativo.
  final DisposeVisionCamera dispose;

  /// Inserta la superficie visual del plugin sin exponer su controlador.
  final WidgetBuilder previewBuilder;
}
