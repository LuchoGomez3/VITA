import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_camera_info.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Encapsula cámara y acelerómetro detrás de tipos propios de la feature.
class DeviceVisionCameraRepository implements VisionCameraRepository {
  CameraController? _controller;
  Future<void> _cameraOperation = Future<void>.value();
  VisionDeviceOrientation _orientation = VisionDeviceOrientation.portraitUp;

  @override
  Stream<VisionDeviceOrientation> get orientationChanges => accelerometerEventStream(
    samplingPeriod: SensorInterval.uiInterval,
  ).map(_orientationFor).where((orientation) => orientation != null).cast<VisionDeviceOrientation>().distinct();

  /// Construye exclusivamente la superficie nativa que requiere el plugin.
  Widget buildPreview(BuildContext context) {
    final controller = _controller;
    return controller == null || !controller.value.isInitialized ? const SizedBox.shrink() : CameraPreview(controller);
  }

  @override
  Future<VisionCameraInfo> initialize() {
    final result = Completer<VisionCameraInfo>();
    _cameraOperation = _cameraOperation.then((_) async {
      try {
        await _controller?.dispose();
        _controller = null;
        final cameras = await availableCameras();
        final rear = cameras.where((camera) => camera.lensDirection == CameraLensDirection.back).firstOrNull;
        if (rear == null) throw const VisionDeviceException();
        final controller = CameraController(rear, ResolutionPreset.high, enableAudio: false);
        await controller.initialize();
        _controller = controller;
        result.complete(VisionCameraInfo(aspectRatio: controller.value.aspectRatio));
      } on VisionWeighingException catch (error, stack) {
        result.completeError(error, stack);
      } on Exception catch (error, stack) {
        result.completeError(VisionDeviceException(cause: error), stack);
      }
    });
    return result.future;
  }

  @override
  Future<Uint8List> capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const VisionDeviceException();
    }
    try {
      return await (await controller.takePicture()).readAsBytes();
    } on Exception catch (error) {
      throw VisionDeviceException(cause: error);
    }
  }

  @override
  Future<void> dispose() {
    final result = Completer<void>();
    _cameraOperation = _cameraOperation.then((_) async {
      try {
        await _controller?.dispose();
        _controller = null;
        result.complete();
      } on Exception catch (error, stack) {
        result.completeError(VisionDeviceException(cause: error), stack);
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
