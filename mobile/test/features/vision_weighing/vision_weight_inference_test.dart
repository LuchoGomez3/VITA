import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/services/tflite_weight_estimator.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_weight_estimate.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_capture_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_estimator_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/confirm_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/estimate_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/process_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/save_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_cubit.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_view_data.dart';
import 'package:image/image.dart' as img;

class _CaptureRepository implements VisionCaptureRepository {
  @override
  Future<VisionCapture> prepare(Uint8List bytes) async => VisionCapture(
    jpegBytes: bytes,
    quality: CaptureQuality.reviewRequired,
    sharpness: 120,
  );
}

class _WeightRepository implements VisionWeightEstimatorRepository, VisionWeightRepository {
  double prediction = 390;
  int saves = 0;
  String? savedAnimalId;
  double? savedWeight;

  @override
  Future<VisionWeightEstimate> estimateWeight(Uint8List jpegBytes) async => VisionWeightEstimate(
    weightKg: prediction,
    lowerKg: prediction - 85.26577758789062,
    upperKg: prediction + 85.26577758789062,
    targetCoverage: .9,
  );

  @override
  Future<void> saveEstimate({required String animalId, required double weightKg, required Uint8List jpegBytes}) async {
    saves++;
    savedAnimalId = animalId;
    savedWeight = weightKg;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('modelo ausente da un diagnóstico recuperable sin cargar TFLite', () async {
    final estimator = TfliteWeightEstimator(bundle: _MissingAssets());
    await expectLater(estimator.estimateWeight(Uint8List(0)), throwsA(isA<VisionModelUnavailableException>()));
  });

  test('permite sustituir las rutas del modelo y su margen desde composición', () async {
    final bundle = _ReplacementAssets();
    final estimator = TfliteWeightEstimator(
      bundle: bundle,
      modelAsset: 'assets/models/replacement.tflite',
      calibrationAsset: 'assets/models/replacement.json',
    );
    await expectLater(estimator.estimateWeight(Uint8List(0)), throwsA(isA<VisionModelUnavailableException>()));
    expect(bundle.requested, ['assets/models/replacement.tflite', 'assets/models/replacement.json']);
  });

  test('incluye un modelo TFLite local y su margen real en el bundle', () async {
    final model = await rootBundle.load(TfliteWeightEstimator.defaultModelAsset);
    // Identificador del formato FlatBuffer de TFLite, sin cargar librerías nativas.
    expect(model.buffer.asUint8List(model.offsetInBytes + 4, 4), [84, 70, 76, 51]);
    expect(model.lengthInBytes, greaterThan(0));
    final calibration = parseWeightCalibration(
      await rootBundle.loadString(TfliteWeightEstimator.defaultCalibrationAsset),
    );
    expect(calibration.marginKg, closeTo(85.2658, .001));
    expect(calibration.targetCoverage, .9);
  });

  test('lee el margen empaquetado y limita a cero el extremo inferior', () async {
    final source = await rootBundle.loadString(TfliteWeightEstimator.defaultCalibrationAsset);
    final calibration = parseWeightCalibration(source);
    final estimate = applyWeightInterval(60, calibration.marginKg, calibration.targetCoverage);

    expect(calibration.marginKg, closeTo(85.2658, .001));
    expect(estimate.lowerKg, 0);
    expect(estimate.upperKg, closeTo(145.2658, .001));
    expect(estimate.targetCoverage, .9);
  });

  test('prepara exactamente RGB 224×224 en el rango MobileNetV2', () {
    final source = img.Image(width: 224, height: 224);
    img.fill(source, color: img.ColorRgb8(255, 127, 0));
    final input = prepareWeightInput(Uint8List.fromList(img.encodePng(source)));

    expect(input.length, 224 * 224 * 3);
    expect(input[0], closeTo(1, 0.001));
    expect(input[1], closeTo(-0.0039, 0.001));
    expect(input[2], closeTo(-1, 0.001));
  });

  test('infiere offline, exige revisión y guarda una sola vez con animal', () async {
    final repository = _WeightRepository();
    final cubit = VisionCaptureCubit(
      ProcessVisionCapture(PrepareVisionCapture(_CaptureRepository()), EstimateVisionWeight(repository)),
      const ConfirmVisionCapture(),
      SaveVisionWeight(repository),
    );
    addTearDown(cubit.close);

    await cubit.process(Uint8List(3));
    final prediction = (cubit.state as Data<VisionCaptureViewData>).data;
    expect(prediction.capture.estimatedWeightKg, 390);
    expect(prediction.capture.estimatedWeightLowerKg, closeTo(304.73, .01));
    expect(prediction.capture.estimatedWeightUpperKg, closeTo(475.27, .01));
    expect(prediction.capture.intervalTargetCoverage, .9);
    expect(prediction.inferenceMilliseconds, isNotNull);
    await cubit.save('animal-1');
    expect(repository.saves, 0);

    cubit.confirm(sharpnessConfirmed: true, completeAnimalConfirmed: true, lateralConfirmed: true);
    await cubit.save(' animal-1 ');
    await cubit.save('animal-1');
    expect(repository.saves, 1);
    expect(repository.savedAnimalId, 'animal-1');
    expect(repository.savedWeight, 390);
    expect((cubit.state as Data<VisionCaptureViewData>).data.saved, isTrue);
  });

  test('rechaza peso inválido sin crear un pesaje', () async {
    final repository = _WeightRepository()..prediction = double.nan;
    final cubit = VisionCaptureCubit(
      ProcessVisionCapture(PrepareVisionCapture(_CaptureRepository()), EstimateVisionWeight(repository)),
      const ConfirmVisionCapture(),
      SaveVisionWeight(repository),
    );
    addTearDown(cubit.close);

    await cubit.process(Uint8List(3));
    expect(cubit.state, isA<ResultError<VisionCaptureViewData>>());
    expect(repository.saves, 0);
  });
}

class _MissingAssets extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => throw FlutterError('Missing test asset');
}

class _ReplacementAssets extends CachingAssetBundle {
  final requested = <String>[];

  @override
  Future<ByteData> load(String key) async {
    requested.add(key);
    if (key.endsWith('.json')) throw FlutterError('Missing replacement metadata');
    return ByteData(8);
  }
}
