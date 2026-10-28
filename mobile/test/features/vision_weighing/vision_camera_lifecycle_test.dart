import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_camera_info.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/capture_vision_photo.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/dispose_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/initialize_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/watch_vision_camera_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/models/vision_camera_dependencies.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
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

  testWidgets('muestra permiso denegado y permite volver a abrir', (tester) async {
    final repository = _PendingCameraRepository();
    await tester.pumpWidget(MaterialApp(home: _camera(repository)));
    repository.openings.single.completeError(const VisionCameraPermissionException(requiresSettings: true));
    await tester.pump();
    expect(find.text(VisionWeighingStrings.cameraPermissionSettings), findsOneWidget);
    await tester.tap(find.text(VisionWeighingStrings.retryCamera));
    await tester.pump();
    repository.openings.last.complete(const VisionCameraInfo(aspectRatio: 16 / 9));
    await tester.pump();
    expect(find.byKey(const Key('preview')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reanuda el sensor tras inactive, hidden y paused y cancela la suscripción al salir', (tester) async {
    var cancellations = 0;
    final orientations = StreamController<VisionDeviceOrientation>(onCancel: () => cancellations++);
    final repository = _PendingCameraRepository()..orientations = orientations.stream;
    var updates = 0;
    await tester.pumpWidget(MaterialApp(home: _camera(repository, onOrientation: (_) => updates++)));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    orientations.add(VisionDeviceOrientation.landscapeLeft);
    await tester.pump();
    expect(updates, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(cancellations, 1);
    unawaited(orientations.close());
    await tester.pump();
  });

  testWidgets('una captura que termina tras salir no invoca callbacks de la página', (tester) async {
    final orientations = StreamController<VisionDeviceOrientation>();
    final repository = _PendingCameraRepository()
      ..orientations = orientations.stream
      ..capture = Completer<Uint8List>();
    var captures = 0;
    await tester.pumpWidget(MaterialApp(home: _camera(repository, onCaptured: (_, _) async => captures++)));
    repository.openings.single.complete(const VisionCameraInfo(aspectRatio: 16 / 9));
    orientations.add(VisionDeviceOrientation.landscapeLeft);
    await tester.pump();
    await tester.tap(find.byTooltip(VisionWeighingStrings.capture));
    await tester.pumpWidget(const SizedBox());
    repository.capture!.complete(Uint8List(0));
    await tester.pump();
    expect(captures, 0);
    expect(tester.takeException(), isNull);
    unawaited(orientations.close());
    await tester.pump();
  });

  testWidgets('conserva la orientación del disparo aunque el teléfono gire durante la captura', (tester) async {
    final orientations = StreamController<VisionDeviceOrientation>();
    final repository = _PendingCameraRepository()
      ..orientations = orientations.stream
      ..capture = Completer<Uint8List>();
    var captures = 0;
    await tester.pumpWidget(MaterialApp(home: _camera(repository, onCaptured: (_, _) async => captures++)));
    repository.openings.single.complete(const VisionCameraInfo(aspectRatio: 16 / 9));
    orientations.add(VisionDeviceOrientation.landscapeRight);
    await tester.pump();
    await tester.tap(find.byTooltip(VisionWeighingStrings.capture));
    orientations.add(VisionDeviceOrientation.portraitUp);
    await tester.pump();
    repository.capture!.complete(Uint8List(3));
    await tester.pump();
    expect(repository.requestedOrientation, VisionDeviceOrientation.landscapeRight);
    expect(captures, 1);
    await tester.pumpWidget(const SizedBox());
    unawaited(orientations.close());
    await tester.pump();
  });
}

VisionCamera _camera(
  _PendingCameraRepository repository, {
  ValueChanged<VisionDeviceOrientation>? onOrientation,
  Future<void> Function(Uint8List, Stopwatch)? onCaptured,
}) => VisionCamera(
  onCaptured: onCaptured ?? (_, _) async {},
  onInitializationCompleted: () {},
  onDeviceOrientationChanged: onOrientation ?? (_) {},
  onPortraitCaptureAttempt: () {},
  showControls: true,
  dependencies: VisionCameraDependencies(
    initialize: InitializeVisionCamera(repository),
    capture: CaptureVisionPhoto(repository),
    watchOrientation: WatchVisionCameraOrientation(repository),
    dispose: DisposeVisionCamera(repository),
    previewBuilder: (_) => const SizedBox(key: Key('preview')),
  ),
);

/// Permite completar las aperturas en el orden que provoca el diálogo nativo.
class _PendingCameraRepository implements VisionCameraRepository {
  final openings = <Completer<VisionCameraInfo>>[];
  int disposals = 0;
  Stream<VisionDeviceOrientation> orientations = const Stream.empty();
  Completer<Uint8List>? capture;
  VisionDeviceOrientation? requestedOrientation;

  @override
  Stream<VisionDeviceOrientation> get orientationChanges => orientations;

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
  Future<Uint8List> capturePhoto({required VisionDeviceOrientation orientation}) async {
    requestedOrientation = orientation;
    return capture == null ? Uint8List(0) : await capture!.future;
  }
}
