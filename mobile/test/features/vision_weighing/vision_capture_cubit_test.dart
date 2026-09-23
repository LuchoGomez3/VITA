import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_weight_estimate.dart';
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
  @override
  Future<void> saveEstimate({required String animalId, required double weightKg}) async {}
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
}
