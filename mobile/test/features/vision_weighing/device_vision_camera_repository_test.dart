import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/services/device_vision_camera_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/models/vision_camera_preview_adapter.dart';

const _rear = CameraDescription(name: 'rear', lensDirection: CameraLensDirection.back, sensorOrientation: 90);

class _Controller extends CameraController {
  _Controller({this.failure, this.opening, this.closing}) : super(_rear, ResolutionPreset.high, enableAudio: false);

  final CameraException? failure;
  final Completer<void>? opening;
  final Completer<void>? closing;
  int disposals = 0;
  final captureCalls = <Object>[];
  bool failCapture = false;

  @override
  Future<void> lockCaptureOrientation([DeviceOrientation? orientation]) async => captureCalls.add(orientation!);

  @override
  Future<void> unlockCaptureOrientation() async => captureCalls.add('unlock');

  @override
  Future<XFile> takePicture() async {
    captureCalls.add('capture');
    if (failCapture) throw CameraException('capture_failed', 'Test failure');
    return XFile.fromData(Uint8List.fromList([1, 2, 3]));
  }

  @override
  Future<void> initialize() async {
    await opening?.future;
    if (failure case final error?) throw error;
    value = value.copyWith(isInitialized: true, previewSize: const Size(1920, 1080));
  }

  @override
  Future<void> dispose() async {
    disposals++;
    await closing?.future;
    await super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final entry in {
    VisionDeviceOrientation.landscapeLeft: DeviceOrientation.landscapeLeft,
    VisionDeviceOrientation.landscapeRight: DeviceOrientation.landscapeRight,
  }.entries) {
    test('fija ${entry.key} antes de capturar y libera el bloqueo al terminar', () async {
      final controller = _Controller();
      final repository = DeviceVisionCameraRepository(
        getCameras: () async => [_rear],
        createController: (_) => controller,
      );
      await repository.initialize();
      final bytes = await repository.capturePhoto(orientation: entry.key);
      expect(bytes, [1, 2, 3]);
      expect(controller.captureCalls, [entry.value, 'capture', 'unlock']);
      await repository.dispose();
    });
  }

  test('libera la orientación también cuando falla la captura y permite reintentar', () async {
    final controller = _Controller()..failCapture = true;
    final repository = DeviceVisionCameraRepository(
      getCameras: () async => [_rear],
      createController: (_) => controller,
    );
    await repository.initialize();
    await expectLater(
      repository.capturePhoto(orientation: VisionDeviceOrientation.landscapeLeft),
      throwsA(isA<VisionDeviceException>()),
    );
    expect(controller.captureCalls.last, 'unlock');
    controller.failCapture = false;
    await repository.capturePhoto(orientation: VisionDeviceOrientation.landscapeRight);
    expect(controller.captureCalls, [
      DeviceOrientation.landscapeLeft,
      'capture',
      'unlock',
      DeviceOrientation.landscapeRight,
      'capture',
      'unlock',
    ]);
    await repository.dispose();
  });

  test('informa hardware ausente sin crear un controller', () async {
    final repository = DeviceVisionCameraRepository(getCameras: () async => []);
    await expectLater(repository.initialize(), throwsA(isA<VisionCameraUnavailableException>()));
    await repository.dispose();
  });

  for (final code in ['CameraAccessDenied', 'CameraAccessDeniedWithoutPrompt', 'CameraAccessRestricted']) {
    test('libera el controller tras $code y permite reintentar', () async {
      final denied = _Controller(failure: CameraException(code, 'denied'));
      final accepted = _Controller();
      final controllers = [denied, accepted];
      final repository = DeviceVisionCameraRepository(
        getCameras: () async => [_rear],
        createController: (_) => controllers.removeAt(0),
      );
      await expectLater(
        repository.initialize(),
        throwsA(
          isA<VisionCameraPermissionException>().having(
            (error) => error.requiresSettings,
            'requiresSettings',
            code != 'CameraAccessDenied',
          ),
        ),
      );
      expect(denied.disposals, 1);
      expect((await repository.initialize()).aspectRatio, closeTo(16 / 9, .001));
      await repository.dispose();
      expect(accepted.disposals, 1);
    });
  }

  test('serializa apertura, cierre y reapertura y retira el preview antes del cierre nativo', () async {
    final opening = Completer<void>();
    final closing = Completer<void>();
    final first = _Controller(opening: opening, closing: closing);
    final second = _Controller();
    final controllers = [first, second];
    final preview = VisionCameraPreviewAdapter();
    final changes = <CameraController?>[];
    final repository = DeviceVisionCameraRepository(
      getCameras: () async => [_rear],
      createController: (_) => controllers.removeAt(0),
      onControllerChanged: (controller) {
        changes.add(controller);
        preview.controller = controller;
      },
    );
    final initialize = repository.initialize();
    final dispose = repository.dispose();
    final reopen = repository.initialize();
    await Future<void>.delayed(Duration.zero);
    expect(first.disposals, 0);
    opening.complete();
    await initialize;
    await Future<void>.delayed(Duration.zero);
    expect(first.disposals, 1);
    expect(controllers, hasLength(1));
    final context = _UnusedContext();
    expect(preview.buildPreview(context), isA<SizedBox>());
    expect(changes.last, isNull);
    closing.complete();
    await dispose;
    await reopen;
    final surface = preview.buildPreview(context);
    expect(surface, isA<CameraPreview>());
    expect((surface as CameraPreview).controller, same(second));
    await repository.dispose();
    expect(second.disposals, 1);
    expect(preview.buildPreview(context), isA<SizedBox>());
    expect(changes.whereType<CameraController>(), [first, second]);
  });
}

class _UnusedContext extends Fake implements BuildContext {}
