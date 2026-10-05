import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_camera_info.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/capture_vision_photo.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/dispose_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/initialize_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/watch_vision_camera_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/models/vision_camera_dependencies.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/vision_camera.dart';

void main() {
  testWidgets('volver de permisos no permite que una apertura vieja cierre la cámara nueva', (tester) async {
    final repository = _PendingCameraRepository();
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: VisionCamera(
          onCaptured: (_, _) async {},
          onInitializationCompleted: () => completions++,
          onDeviceOrientationChanged: (_) {},
          onPortraitCaptureAttempt: () {},
          showControls: false,
          dependencies: VisionCameraDependencies(
            initialize: InitializeVisionCamera(repository),
            capture: CaptureVisionPhoto(repository),
            watchOrientation: WatchVisionCameraOrientation(repository),
            dispose: DisposeVisionCamera(repository),
            previewBuilder: (_) => const ColoredBox(key: Key('preview'), color: Colors.black),
          ),
        ),
      ),
    );

    // El diálogo de permisos interrumpe la primera apertura y luego reanuda
    // la ruta. Controlamos el orden de los futures para reproducir la carrera.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(repository.openings, hasLength(2));
    expect(repository.disposals, 1);

    repository.openings.last.complete(const VisionCameraInfo(aspectRatio: 16 / 9));
    await tester.pump();
    repository.openings.first.complete(const VisionCameraInfo(aspectRatio: 16 / 9));
    await tester.pump();

    expect(repository.disposals, 1);
    expect(completions, 1);
    expect(find.byKey(const Key('preview')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    expect(repository.disposals, 2);
  });

  testWidgets('una apertura que termina después de salir no vuelve a cerrar la cámara', (tester) async {
    final repository = _PendingCameraRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: VisionCamera(
          onCaptured: (_, _) async {},
          onInitializationCompleted: () {},
          onDeviceOrientationChanged: (_) {},
          onPortraitCaptureAttempt: () {},
          showControls: false,
          dependencies: VisionCameraDependencies(
            initialize: InitializeVisionCamera(repository),
            capture: CaptureVisionPhoto(repository),
            watchOrientation: WatchVisionCameraOrientation(repository),
            dispose: DisposeVisionCamera(repository),
            previewBuilder: (_) => const SizedBox(),
          ),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    repository.openings.single.complete(const VisionCameraInfo(aspectRatio: 16 / 9));
    await tester.pump();
    expect(repository.disposals, 1);
    expect(tester.takeException(), isNull);
  });
}

/// Permite completar las aperturas en el orden que provoca el diálogo nativo.
class _PendingCameraRepository implements VisionCameraRepository {
  final openings = <Completer<VisionCameraInfo>>[];
  int disposals = 0;

  @override
  Stream<VisionDeviceOrientation> get orientationChanges => const Stream.empty();

  @override
  Future<VisionCameraInfo> initialize() {
    final opening = Completer<VisionCameraInfo>();
    openings.add(opening);
    return opening.future;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }

  @override
  Future<Uint8List> capturePhoto() async => Uint8List(0);
}
