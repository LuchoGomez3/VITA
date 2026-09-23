import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/widgets/app_status_indicator.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_camera_info.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_device_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_animal_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_camera_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/capture_vision_photo.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/dispose_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/get_vision_animal_options.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/initialize_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/watch_vision_camera_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_view_data.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/models/vision_camera_dependencies.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/vision_weighing_content.dart';

void main() {
  testWidgets('durante la inferencia usa el indicador circular compartido', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VisionWeighingContent(
          state: const ResultState<VisionCaptureViewData>.loading(),
          getAnimalOptions: GetVisionAnimalOptions(_EmptyAnimalRepository()),
          calibration: false,
          selectingPhoto: false,
          onAttachPhoto: () {},
          cameraControlsVisible: true,
          phoneOrientation: VisionDeviceOrientation.landscapeRight,
          orientationWarningHighlighted: false,
          onPortraitCaptureAttempt: () {},
          captureOrientation: VisionDeviceOrientation.landscapeRight,
          onCaptured: (bytes, timer) async {},
          onCameraInitializationCompleted: () {},
          onDeviceOrientationChanged: (orientation) {},
          onCalibrationChanged: (enabled) {},
          cameraDependencies: _cameraDependencies(),
        ),
      ),
    );

    expect(find.byType(AppStatusIndicator), findsOneWidget);
    expect(tester.widget<AppStatusIndicator>(find.byType(AppStatusIndicator)).isLoading, isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(VisionWeighingStrings.processing), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}

VisionCameraDependencies _cameraDependencies() {
  final repository = _CameraRepository();
  return VisionCameraDependencies(
    initialize: InitializeVisionCamera(repository),
    capture: CaptureVisionPhoto(repository),
    watchOrientation: WatchVisionCameraOrientation(repository),
    dispose: DisposeVisionCamera(repository),
    previewBuilder: (_) => const SizedBox.shrink(),
  );
}

class _CameraRepository implements VisionCameraRepository {
  @override
  Stream<VisionDeviceOrientation> get orientationChanges => const Stream.empty();

  @override
  Future<Uint8List> capturePhoto() async => Uint8List(0);

  @override
  Future<void> dispose() async {}

  @override
  Future<VisionCameraInfo> initialize() async => const VisionCameraInfo(aspectRatio: 1);
}

class _EmptyAnimalRepository implements VisionAnimalRepository {
  @override
  Future<VisionAnimalOptions> getOptions() async => const VisionAnimalOptions(animals: [], establishments: []);
}
