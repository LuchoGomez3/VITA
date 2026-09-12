import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/capture_review.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/landscape_framing_reminder.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/vision_camera_header.dart';

/// Alterna entre el visor, el procesamiento y la revisión de la captura.
class VisionWeighingContent extends StatelessWidget {
  /// Crea el contenido visual de acuerdo con el estado coordinado por el Cubit.
  const VisionWeighingContent({
    required this.state,
    required this.calibration,
    required this.selectingPhoto,
    required this.onAttachPhoto,
    required this.cameraControlsVisible,
    required this.phoneOrientation,
    required this.orientationWarningHighlighted,
    required this.onPortraitCaptureAttempt,
    required this.captureOrientation,
    required this.onCaptured,
    required this.onCameraInitializationCompleted,
    required this.onDeviceOrientationChanged,
    required this.onCalibrationChanged,
    super.key,
  });

  /// Estado del análisis local de la fotografía.
  final ResultState<VisionCapture> state;

  /// Indica si se solicitará el peso real de balanza.
  final bool calibration;

  /// Evita otra captura mientras se elige y se lee una foto de prueba.
  final bool selectingPhoto;

  /// Abre la galería y entrega la imagen al mismo flujo de revisión.
  final VoidCallback onAttachPhoto;

  /// Controla la aparición del encabezado y el disparador.
  final bool cameraControlsVisible;

  /// Orientación física actual informada por el acelerómetro.
  final DeviceOrientation phoneOrientation;

  /// Destaca el aviso durante el parpadeo posterior a una toma bloqueada.
  final bool orientationWarningHighlighted;

  /// Comunica una toma bloqueada por sostener el teléfono en vertical.
  final VoidCallback onPortraitCaptureAttempt;

  /// Orientación guardada en el instante en que se tomó la fotografía.
  final DeviceOrientation captureOrientation;

  /// Entrega los bytes capturados a la página para iniciar el análisis.
  final Future<void> Function(Uint8List) onCaptured;

  /// Informa que el sensor terminó de inicializarse.
  final VoidCallback onCameraInitializationCompleted;

  /// Comunica cada cambio estable de orientación física.
  final ValueChanged<DeviceOrientation> onDeviceOrientationChanged;

  /// Comunica cambios en el modo calibración.
  final ValueChanged<bool> onCalibrationChanged;

  @override
  Widget build(BuildContext context) {
    if (state case Data<VisionCapture>(:final data)) {
      return Scaffold(
        appBar: AppBar(title: const Text(VisionWeighingStrings.review)),
        body: SafeArea(
          child: CaptureReview(
            capture: data,
            calibration: calibration,
            captureOrientation: captureOrientation,
          ),
        ),
      );
    }
    return _CameraCaptureContent(
      state: state,
      calibration: calibration,
      selectingPhoto: selectingPhoto,
      onAttachPhoto: onAttachPhoto,
      cameraControlsVisible: cameraControlsVisible,
      phoneOrientation: phoneOrientation,
      orientationWarningHighlighted: orientationWarningHighlighted,
      onPortraitCaptureAttempt: onPortraitCaptureAttempt,
      onCaptured: onCaptured,
      onCameraInitializationCompleted: onCameraInitializationCompleted,
      onDeviceOrientationChanged: onDeviceOrientationChanged,
      onCalibrationChanged: onCalibrationChanged,
    );
  }
}

class _CameraCaptureContent extends StatelessWidget {
  const _CameraCaptureContent({
    required this.state,
    required this.calibration,
    required this.selectingPhoto,
    required this.onAttachPhoto,
    required this.cameraControlsVisible,
    required this.phoneOrientation,
    required this.orientationWarningHighlighted,
    required this.onPortraitCaptureAttempt,
    required this.onCaptured,
    required this.onCameraInitializationCompleted,
    required this.onDeviceOrientationChanged,
    required this.onCalibrationChanged,
  });

  final ResultState<VisionCapture> state;
  final bool calibration;
  final bool selectingPhoto;
  final VoidCallback onAttachPhoto;
  final bool cameraControlsVisible;
  final DeviceOrientation phoneOrientation;
  final bool orientationWarningHighlighted;
  final VoidCallback onPortraitCaptureAttempt;
  final Future<void> Function(Uint8List) onCaptured;
  final VoidCallback onCameraInitializationCompleted;
  final ValueChanged<DeviceOrientation> onDeviceOrientationChanged;
  final ValueChanged<bool> onCalibrationChanged;

  @override
  Widget build(BuildContext context) {
    final busy = state is Loading<VisionCapture>;
    final horizontal = switch (phoneOrientation) {
      DeviceOrientation.landscapeLeft || DeviceOrientation.landscapeRight => true,
      DeviceOrientation.portraitUp || DeviceOrientation.portraitDown => false,
    };
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (state is Initial<VisionCapture>)
            VisionCamera(
              onCaptured: onCaptured,
              onInitializationCompleted: onCameraInitializationCompleted,
              onDeviceOrientationChanged: onDeviceOrientationChanged,
              onPortraitCaptureAttempt: onPortraitCaptureAttempt,
              showControls: cameraControlsVisible && !selectingPhoto,
            ),
          if (busy) const Center(child: CircularProgressIndicator()),
          if (cameraControlsVisible)
            VisionCameraHeader(
              orientation: phoneOrientation,
              orientationWarningHighlighted: orientationWarningHighlighted,
              calibration: calibration,
              busy: busy || selectingPhoto,
              onAttachPhoto: onAttachPhoto,
              onCalibrationChanged: onCalibrationChanged,
            ),
          if (cameraControlsVisible && horizontal) LandscapeFramingReminder(orientation: phoneOrientation),
        ],
      ),
    );
  }
}
