import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/repositories/brick_vision_animal_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/repositories/brick_vision_weight_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/repositories/image_picker_vision_photo_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/repositories/local_vision_capture_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/services/device_vision_camera_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/services/tflite_weight_estimator.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/capture_vision_photo.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/confirm_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/dispose_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/estimate_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/get_vision_animal_options.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/initialize_vision_camera.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/pick_vision_photo.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/process_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/save_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/watch_vision_camera_orientation.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_cubit.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/models/vision_camera_dependencies.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/models/vision_camera_preview_adapter.dart';

/// Provee las identidades locales al formulario de revisión de la foto.
GetVisionAnimalOptions createVisionAnimalOptionsUseCase() => GetVisionAnimalOptions(
  BrickVisionAnimalRepository(
    BrickAnimalStore.instance,
    const EstablishmentCatalog(secureStorage: FlutterSecureStorageService()),
  ),
);

/// Oculta `image_picker` detrás del caso de uso consumido por la página.
PickVisionPhoto createPickVisionPhotoUseCase() => PickVisionPhoto(ImagePickerVisionPhotoRepository());

/// Crea una sesión independiente para que cada ruta posea su cámara nativa.
VisionCameraDependencies createVisionCameraDependencies() {
  final preview = VisionCameraPreviewAdapter();
  final repository = DeviceVisionCameraRepository(onControllerChanged: (controller) => preview.controller = controller);
  return VisionCameraDependencies(
    initialize: InitializeVisionCamera(repository),
    capture: CaptureVisionPhoto(repository),
    watchOrientation: WatchVisionCameraOrientation(repository),
    dispose: DisposeVisionCamera(repository),
    previewBuilder: preview.buildPreview,
  );
}

/// Compone inferencia local y guardado offline para cada captura.
VisionCaptureCubit createVisionCaptureCubit() {
  final weightRepository = BrickVisionWeightRepository(
    BrickAnimalStore.instance,
    BrickPesajeStore.instance,
    const EstablishmentCatalog(secureStorage: FlutterSecureStorageService()),
  );
  return VisionCaptureCubit(
    ProcessVisionCapture(
      const PrepareVisionCapture(LocalVisionCaptureRepository()),
      EstimateVisionWeight(TfliteWeightEstimator()),
    ),
    const ConfirmVisionCapture(),
    SaveVisionWeight(weightRepository),
  );
}
