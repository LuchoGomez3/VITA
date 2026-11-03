import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_camera_info.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Encapsula cámara y acelerómetro detrás de tipos propios de la feature.
class DeviceVisionCameraRepository implements VisionCameraRepository {
  /// Inyecta el plugin para probar permisos y carreras sin hardware.
  DeviceVisionCameraRepository({
    Future<List<CameraDescription>> Function()? getCameras,
    CameraController Function(CameraDescription)? createController,
    void Function(CameraController?)? onControllerChanged,
  }) : _getCameras = getCameras ?? availableCameras,
       _createController = createController ?? _newController,
       _onControllerChanged = onControllerChanged;

  final Future<List<CameraDescription>> Function() _getCameras;
  final CameraController Function(CameraDescription) _createController;
  final void Function(CameraController?)? _onControllerChanged;
  CameraController? _controller;

  static CameraController _newController(CameraDescription description) =>
      CameraController(description, ResolutionPreset.high, enableAudio: false);
  Future<void> _cameraOperation = Future<void>.value();
  VisionDeviceOrientation _orientation = VisionDeviceOrientation.portraitUp;

  @override
  Stream<VisionDeviceOrientation> get orientationChanges => accelerometerEventStream(
    samplingPeriod: SensorInterval.uiInterval,
  ).map(_orientationFor).where((orientation) => orientation != null).cast<VisionDeviceOrientation>().distinct();

  @override
  Future<VisionCameraInfo> initialize() => _enqueue(() async {
    await _closeController();
    final cameras = await _getCameras();
    final rear = cameras.where((camera) => camera.lensDirection == CameraLensDirection.back).firstOrNull;
    if (rear == null) throw const VisionCameraUnavailableException();
    final controller = _createController(rear);
    try {
      await controller.initialize();
      _controller = controller;
      _onControllerChanged?.call(controller);
      return VisionCameraInfo(aspectRatio: controller.value.aspectRatio);
    } on CameraException catch (error) {
      await controller.dispose();
      if (error.code == 'CameraAccessDenied' ||
          error.code == 'CameraAccessDeniedWithoutPrompt' ||
          error.code == 'CameraAccessRestricted') {
        throw VisionCameraPermissionException(
          requiresSettings: error.code != 'CameraAccessDenied',
          cause: error,
        );
      }
      throw VisionDeviceException(cause: error);
    } on Object {
      await controller.dispose();
      rethrow;
    }
  });

  @override
  Future<Uint8List> capturePhoto({required VisionDeviceOrientation orientation}) => _enqueue(() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const VisionDeviceException();
    }
    try {
      // CameraX no debe usar la rotación portrait de la interfaz como fallback.
      // El bloqueo también fija AVFoundation aunque el teléfono se mueva luego.
      await controller.lockCaptureOrientation(_captureOrientationFor(orientation));
      try {
        return await (await controller.takePicture()).readAsBytes();
      } finally {
        await controller.unlockCaptureOrientation();
      }
    } on Exception catch (error) {
      throw VisionDeviceException(cause: error);
    }
  });

  DeviceOrientation _captureOrientationFor(VisionDeviceOrientation orientation) => switch (orientation) {
    VisionDeviceOrientation.portraitUp => DeviceOrientation.portraitUp,
    VisionDeviceOrientation.portraitDown => DeviceOrientation.portraitDown,
    VisionDeviceOrientation.landscapeLeft => DeviceOrientation.landscapeLeft,
    VisionDeviceOrientation.landscapeRight => DeviceOrientation.landscapeRight,
  };

  @override
  Future<void> dispose() => _enqueue(_closeController);

  Future<void> _closeController() async {
    // Retirar la referencia evita construir previews de un controller descartado.
    final previousController = _controller;
    _controller = null;
    _onControllerChanged?.call(null);
    await previousController?.dispose();
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _cameraOperation = _cameraOperation.then((_) async {
      try {
        result.complete(await operation());
      } on Object catch (error, stack) {
        // El fallo llega al caller sin envenenar la cola de cierres posteriores.
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  VisionDeviceOrientation? _orientationFor(AccelerometerEvent event) {
    final horizontalGravity = event.x.abs();
    final verticalGravity = event.y.abs();
    if (math.max(horizontalGravity, verticalGravity) < 4) return null;
    final wasHorizontal = switch (_orientation) {
      VisionDeviceOrientation.landscapeLeft || VisionDeviceOrientation.landscapeRight => true,
      VisionDeviceOrientation.portraitUp || VisionDeviceOrientation.portraitDown => false,
    };
    // La histéresis evita alternancias cuando el teléfono queda cerca de 45°.
    final horizontal = wasHorizontal
        ? horizontalGravity > verticalGravity * .8
        : horizontalGravity > verticalGravity * 1.2;
    return _orientation = horizontal
        ? event.x > 0
              ? VisionDeviceOrientation.landscapeRight
              : VisionDeviceOrientation.landscapeLeft
        : event.y > 0
        ? VisionDeviceOrientation.portraitUp
        : VisionDeviceOrientation.portraitDown;
  }
}
