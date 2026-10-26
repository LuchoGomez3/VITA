import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/get_vision_animal_options.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_view_data.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/models/vision_camera_dependencies.dart';
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
    required this.getAnimalOptions,
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
    required this.cameraDependencies,
    super.key,
  });

  /// Estado del análisis local de la fotografía.
  final ResultState<VisionCaptureViewData> state;

  /// Consulta las opciones locales durante la revisión de la captura.
  final GetVisionAnimalOptions getAnimalOptions;

  /// Indica si se solicitará el peso real de balanza.
  final bool calibration;

  /// Evita otra captura mientras se elige y se lee una foto de prueba.
  final bool selectingPhoto;

  /// Abre la galería y entrega la imagen al mismo flujo de revisión.
  final VoidCallback onAttachPhoto;

  /// Controla la aparición del encabezado y el disparador.
  final bool cameraControlsVisible;

  /// Orientación física actual informada por el acelerómetro.
  final VisionDeviceOrientation phoneOrientation;

  /// Destaca el aviso durante el parpadeo posterior a una toma bloqueada.
  final bool orientationWarningHighlighted;

  /// Comunica una toma bloqueada por sostener el teléfono en vertical.
  final VoidCallback onPortraitCaptureAttempt;

  /// Orientación guardada en el instante en que se tomó la fotografía.
  final VisionDeviceOrientation captureOrientation;

  /// Entrega los bytes capturados a la página para iniciar el análisis.
  final Future<void> Function(Uint8List, Stopwatch) onCaptured;

  /// Informa que el sensor terminó de inicializarse.
  final VoidCallback onCameraInitializationCompleted;

  /// Comunica cada cambio estable de orientación física.
  final ValueChanged<VisionDeviceOrientation> onDeviceOrientationChanged;

  /// Comunica cambios en el modo calibración.
  final ValueChanged<bool> onCalibrationChanged;

  /// Integra cámara y sensor mediante casos de uso inyectados.
  final VisionCameraDependencies cameraDependencies;

  @override
  Widget build(BuildContext context) {
    if (state is Loading<VisionCaptureViewData>) return const _VisionProcessingContent();
    if (state case Data<VisionCaptureViewData>(:final data)) {
      return Scaffold(
        appBar: AppBar(title: const Text(VisionWeighingStrings.review)),
        body: SafeArea(
          child: CaptureReview(
            review: data,
            getAnimalOptions: getAnimalOptions,
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
      cameraDependencies: cameraDependencies,
    );
  }
}

class _VisionProcessingContent extends StatelessWidget {
  const _VisionProcessingContent();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusIndicator(icon: Icons.photo_camera_outlined, color: AppColors.primary, isLoading: true),
          SizedBox(height: AppSpacing.lg),
          Text(VisionWeighingStrings.processing, style: AppTypography.successTitle, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
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
    required this.cameraDependencies,
  });

  final ResultState<VisionCaptureViewData> state;
  final bool calibration;
  final bool selectingPhoto;
  final VoidCallback onAttachPhoto;
  final bool cameraControlsVisible;
  final VisionDeviceOrientation phoneOrientation;
  final bool orientationWarningHighlighted;
  final VoidCallback onPortraitCaptureAttempt;
  final Future<void> Function(Uint8List, Stopwatch) onCaptured;
  final VoidCallback onCameraInitializationCompleted;
  final ValueChanged<VisionDeviceOrientation> onDeviceOrientationChanged;
  final ValueChanged<bool> onCalibrationChanged;
  final VisionCameraDependencies cameraDependencies;

  @override
  Widget build(BuildContext context) {
    final horizontal = switch (phoneOrientation) {
      VisionDeviceOrientation.landscapeLeft || VisionDeviceOrientation.landscapeRight => true,
      VisionDeviceOrientation.portraitUp || VisionDeviceOrientation.portraitDown => false,
    };
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (state is Initial<VisionCaptureViewData>)
            VisionCamera(
              onCaptured: onCaptured,
              onInitializationCompleted: onCameraInitializationCompleted,
              onDeviceOrientationChanged: onDeviceOrientationChanged,
              onPortraitCaptureAttempt: onPortraitCaptureAttempt,
              showControls: cameraControlsVisible && !selectingPhoto,
              dependencies: cameraDependencies,
            ),
          if (cameraControlsVisible)
            VisionCameraHeader(
              orientation: phoneOrientation,
              orientationWarningHighlighted: orientationWarningHighlighted,
              calibration: calibration,
              busy: selectingPhoto,
              onAttachPhoto: onAttachPhoto,
              onCalibrationChanged: onCalibrationChanged,
            ),
          if (cameraControlsVisible && horizontal) LandscapeFramingReminder(orientation: phoneOrientation),
        ],
      ),
    );
  }
}
