import 'dart:async';
import 'dart:developer' as developer;

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

/// Ensambla la feature manteniendo codecs e isolates fuera de presentación.
final _estimator = TfliteWeightEstimator();

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
  final repository = DeviceVisionCameraRepository();
  return VisionCameraDependencies(
    initialize: InitializeVisionCamera(repository),
    capture: CaptureVisionPhoto(repository),
    watchOrientation: WatchVisionCameraOrientation(repository),
    dispose: DisposeVisionCamera(repository),
    previewBuilder: repository.buildPreview,
  );
}

/// Conserva el intérprete entre capturas y habilita el guardado offline.
VisionCaptureCubit createVisionCaptureCubit() {
  // La carga comienza al abrir la cámara, antes de que el usuario dispare.
  // Si falla, la inferencia posterior muestra el error de captura existente.
  unawaited(
    _estimator.warmUp().onError((error, stack) {
      developer.log('No se pudo precargar TFLite', name: 'vision_weighing', error: error, stackTrace: stack);
    }),
  );
  final weightRepository = BrickVisionWeightRepository(
    BrickAnimalStore.instance,
    BrickPesajeStore.instance,
  );
  return VisionCaptureCubit(
    ProcessVisionCapture(
      const PrepareVisionCapture(LocalVisionCaptureRepository()),
      EstimateVisionWeight(_estimator),
    ),
    const ConfirmVisionCapture(),
    SaveVisionWeight(weightRepository),
  );
}
