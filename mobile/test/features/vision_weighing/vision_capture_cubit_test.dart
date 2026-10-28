import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_weight_estimate.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_capture_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_estimator_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/confirm_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/estimate_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/parse_calibration_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/prepare_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/process_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/save_vision_weight.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_cubit.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/bloc/vision_capture_view_data.dart';

/// Simula el trabajo del isolate y permite resolverlo después de salir de UI.
class _Repository implements VisionCaptureRepository {
  final result = Completer<VisionCapture>();
  int calls = 0;

  @override
  Future<VisionCapture> prepare(Uint8List bytes) {
    calls++;
    return result.future;
  }
}

class _Estimator implements VisionWeightEstimatorRepository {
  @override
  Future<VisionWeightEstimate> estimateWeight(Uint8List jpegBytes) async =>
      const VisionWeightEstimate(weightKg: 390, lowerKg: 300, upperKg: 480, targetCoverage: .9);
}

class _WeightRepository implements VisionWeightRepository {
  Completer<void>? pending;
  bool fail = false;
  bool denyAccess = false;
  int saves = 0;

  @override
  Future<void> saveEstimate({required String animalId, required double weightKg, required Uint8List jpegBytes}) async {
    saves++;
    await pending?.future;
    if (denyAccess) throw const VisionWeighingAccessDeniedException();
    if (fail) throw const VisionDeviceException();
  }
}

class _MissingModel implements VisionWeightEstimatorRepository {
  @override
  Future<VisionWeightEstimate> estimateWeight(Uint8List jpegBytes) async =>
      throw const VisionModelUnavailableException();
}

VisionCaptureCubit _cubit(_Repository repository) => VisionCaptureCubit(
  ProcessVisionCapture(PrepareVisionCapture(repository), EstimateVisionWeight(_Estimator())),
  const ConfirmVisionCapture(),
  SaveVisionWeight(_WeightRepository()),
);

void main() {
  final bytes = Uint8List(0);
  VisionCapture capture(CaptureQuality quality) => VisionCapture(jpegBytes: bytes, quality: quality, sharpness: 100);

  test('desenfoque estimado pasa a revisión manual y permite reintentar', () async {
    final repository = _Repository();
    final cubit = _cubit(repository);
    final operation = cubit.process(bytes);
    expect(cubit.state, isA<Loading<VisionCaptureViewData>>());
    repository.result.complete(capture(CaptureQuality.blurry));
    await operation;
    expect(cubit.state, isA<Data<VisionCaptureViewData>>());
    cubit.retry();
    expect(cubit.state, isA<Initial<VisionCaptureViewData>>());
    await cubit.close();
  });

  test('rechaza resolución insuficiente antes de la revisión', () async {
    final repository = _Repository();
    final cubit = _cubit(repository);
    final operation = cubit.process(bytes);
    repository.result.complete(capture(CaptureQuality.insufficientResolution));
    await operation;
    expect(cubit.state, isA<ResultError<VisionCaptureViewData>>());
    await cubit.close();
  });

  test('calibración requiere revisión y asocia kilos al borrador', () async {
    final repository = _Repository()..result.complete(capture(CaptureQuality.reviewRequired));
    final cubit = _cubit(repository);
    await cubit.process(bytes);
    cubit.confirm(
      sharpnessConfirmed: false,
      completeAnimalConfirmed: true,
      lateralConfirmed: true,
      calibrationWeightKg: 410,
    );
    expect((cubit.state as Data<VisionCaptureViewData>).data.reviewedCapture, isNull);
    cubit.confirm(
      sharpnessConfirmed: true,
      completeAnimalConfirmed: true,
      lateralConfirmed: true,
      calibrationWeightKg: double.nan,
    );
    expect((cubit.state as Data<VisionCaptureViewData>).data.confirmed, isFalse);
    cubit.confirm(
      sharpnessConfirmed: true,
      completeAnimalConfirmed: true,
      lateralConfirmed: true,
      calibrationWeightKg: 410,
    );
    expect((cubit.state as Data<VisionCaptureViewData>).data.reviewedCapture?.calibrationWeightKg, 410);
    cubit.retry();
    expect(cubit.state, isA<Initial<VisionCaptureViewData>>());
    await cubit.close();
  });

  test('ignora doble disparo y resultados posteriores al cierre', () async {
    final repository = _Repository();
    final cubit = _cubit(repository);
    final pending = cubit.process(bytes);
    await cubit.process(bytes);
    expect(repository.calls, 1);
    await cubit.close();
    repository.result.complete(capture(CaptureQuality.reviewRequired));
    await pending;
  });

  test('un reintento invalida análisis pendiente', () async {
    final repository = _Repository();
    final cubit = _cubit(repository);
    final pending = cubit.process(bytes);
    cubit.retry();
    repository.result.complete(capture(CaptureQuality.reviewRequired));
    await pending;
    expect(cubit.state, isA<Initial<VisionCaptureViewData>>());
    await cubit.close();
  });

  test('fallo del codec se presenta como error recuperable', () async {
    final repository = _Repository();
    final cubit = _cubit(repository);
    final pending = cubit.process(bytes);
    repository.result.completeError(const FormatException());
    await pending;
    expect(cubit.state, isA<ResultError<VisionCaptureViewData>>());
    await cubit.close();
  });

  test('peso argentino permite coma, rechaza valores inválidos y ambiguos', () {
    expect(parseCalibrationWeight(' 410,25 '), 410.25);
    expect(parseCalibrationWeight('410.5'), 410.5);
    for (final input in ['', '0', '-1', 'NaN', 'Infinity', '1e3', '1.200', '1,200.00', 'abc']) {
      expect(parseCalibrationWeight(input), isNull, reason: input);
    }
  });

  test('sin modelo permite revisar y calibrar sin guardar un peso ficticio', () async {
    final repository = _Repository()..result.complete(capture(CaptureQuality.reviewRequired));
    final weights = _WeightRepository();
    final cubit = VisionCaptureCubit(
      ProcessVisionCapture(PrepareVisionCapture(repository), EstimateVisionWeight(_MissingModel())),
      const ConfirmVisionCapture(),
      SaveVisionWeight(weights),
    );
    addTearDown(cubit.close);
    await cubit.process(bytes);
    expect((cubit.state as Data<VisionCaptureViewData>).data.capture.estimatedWeightKg, isNull);
    cubit.confirm(
      sharpnessConfirmed: true,
      completeAnimalConfirmed: true,
      lateralConfirmed: true,
      calibrationWeightKg: 410,
    );
    final reviewed = (cubit.state as Data<VisionCaptureViewData>).data.reviewedCapture;
    expect(reviewed?.calibrationWeightKg, 410);
    await cubit.save('animal-1');
    expect((cubit.state as Data<VisionCaptureViewData>).data.saveResult, isA<ResultError<void>>());
    expect(weights.saves, 0);
  });

  test('serializa el guardado y no emite después de cerrar la sesión', () async {
    final repository = _Repository()..result.complete(capture(CaptureQuality.reviewRequired));
    final weights = _WeightRepository()..pending = Completer<void>();
    final cubit = VisionCaptureCubit(
      ProcessVisionCapture(PrepareVisionCapture(repository), EstimateVisionWeight(_Estimator())),
      const ConfirmVisionCapture(),
      SaveVisionWeight(weights),
    );
    await cubit.process(bytes);
    cubit.confirm(sharpnessConfirmed: true, completeAnimalConfirmed: true, lateralConfirmed: true);
    final saving = cubit.save('animal-1');
    await cubit.save('animal-1');
    cubit.retry();
    await cubit.process(bytes);
    expect(repository.calls, 1);
    expect(weights.saves, 1);
    expect(cubit.state, isA<Data<VisionCaptureViewData>>());
    expect((cubit.state as Data<VisionCaptureViewData>).data.saving, isTrue);
    await cubit.close();
    weights.pending!.complete();
    await saving;
    expect(cubit.isClosed, isTrue);
  });

  test('fallo de persistencia conserva la captura y permite reintentar', () async {
    final repository = _Repository()..result.complete(capture(CaptureQuality.reviewRequired));
    final weights = _WeightRepository()..fail = true;
    final cubit = VisionCaptureCubit(
      ProcessVisionCapture(PrepareVisionCapture(repository), EstimateVisionWeight(_Estimator())),
      const ConfirmVisionCapture(),
      SaveVisionWeight(weights),
    );
    addTearDown(cubit.close);
    await cubit.process(bytes);
    cubit.confirm(sharpnessConfirmed: true, completeAnimalConfirmed: true, lateralConfirmed: true);
    final results = <ResultState<void>>[];
    final subscription = cubit.stream.listen((state) {
      if (state case Data<VisionCaptureViewData>(:final data)) results.add(data.saveResult);
    });
    addTearDown(subscription.cancel);
    final reviewed = (cubit.state as Data<VisionCaptureViewData>).data.reviewedCapture;
    await cubit.save('animal-1');
    expect((cubit.state as Data<VisionCaptureViewData>).data.saved, isFalse);
    expect((cubit.state as Data<VisionCaptureViewData>).data.saveResult, isA<ResultError<void>>());
    expect((cubit.state as Data<VisionCaptureViewData>).data.reviewedCapture, same(reviewed));
    weights.fail = false;
    await cubit.save('animal-1');
    expect((cubit.state as Data<VisionCaptureViewData>).data.saved, isTrue);
    expect(weights.saves, 2);
    await Future<void>.delayed(Duration.zero);
    expect(results, [isA<Loading<void>>(), isA<ResultError<void>>(), isA<Loading<void>>(), isA<Data<void>>()]);
  });

  test('el error de permiso se comunica en el estado de guardado', () async {
    final repository = _Repository()..result.complete(capture(CaptureQuality.reviewRequired));
    final weights = _WeightRepository()..denyAccess = true;
    final cubit = VisionCaptureCubit(
      ProcessVisionCapture(PrepareVisionCapture(repository), EstimateVisionWeight(_Estimator())),
      const ConfirmVisionCapture(),
      SaveVisionWeight(weights),
    );
    addTearDown(cubit.close);
    await cubit.process(bytes);
    cubit.confirm(sharpnessConfirmed: true, completeAnimalConfirmed: true, lateralConfirmed: true);

    await cubit.save('animal-1');

    final data = (cubit.state as Data<VisionCaptureViewData>).data;
    expect(data.saving, isFalse);
    expect(data.saved, isFalse);
    expect((data.saveResult as ResultError<void>).error.code, DomainErrorCode.unauthorized);
    expect((data.saveResult as ResultError<void>).error.reason, isA<VisionWeighingAccessDeniedException>());
  });
}
