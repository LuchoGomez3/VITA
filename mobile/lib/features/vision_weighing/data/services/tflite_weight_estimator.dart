import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_weight_estimate.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_estimator_repository.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Mantiene cargado el modelo de regresión para evitar reiniciarlo en cada foto.
class TfliteWeightEstimator implements VisionWeightEstimatorRepository {
  static const _asset = 'assets/models/peso_bovino_mobilenet_v2.tflite';
  static const _calibrationAsset = 'assets/models/peso_bovino_intervalo.json';
  Future<Interpreter>? _interpreter;
  Future<IsolateInterpreter>? _worker;
  Future<({double marginKg, double targetCoverage})>? _calibration;

  /// Puede invocarse al abrir la cámara para amortizar la carga del modelo.
  Future<void> warmUp() async {
    final interpreter = await (_interpreter ??= Interpreter.fromAsset(_asset));
    _worker ??= IsolateInterpreter.create(address: interpreter.address);
    await _worker;
    await (_calibration ??= _loadCalibration());
  }

  /// Combina el escalar TFLite con el margen calibrado empaquetado localmente.
  @override
  Future<VisionWeightEstimate> estimateWeight(Uint8List jpegBytes) async {
    try {
      await warmUp();
      final input = await compute(prepareWeightInput, jpegBytes);
      final output = <List<double>>[
        [0],
      ];
      await (await _worker!).run(input.buffer, output);
      final calibration = await _calibration!;
      return applyWeightInterval(output.single.single, calibration.marginKg, calibration.targetCoverage);
    } on Exception catch (error) {
      throw VisionDeviceException(cause: error);
    }
  }

  Future<({double marginKg, double targetCoverage})> _loadCalibration() async {
    return parseWeightCalibration(await rootBundle.loadString(_calibrationAsset));
  }
}

/// Lee el margen exportado junto al modelo y comprueba su cobertura declarada.
({double marginKg, double targetCoverage}) parseWeightCalibration(String source) {
  final json = jsonDecode(source) as Map<String, dynamic>;
  final marginKg = (json['margen_kg'] as num).toDouble();
  final targetCoverage = (json['cobertura_objetivo'] as num).toDouble();
  if (!marginKg.isFinite || marginKg < 0 || !targetCoverage.isFinite || targetCoverage <= 0 || targetCoverage >= 1) {
    throw const FormatException('Invalid weight calibration');
  }
  return (marginKg: marginKg, targetCoverage: targetCoverage);
}

/// Aplica en el teléfono el mismo límite inferior que el script de Python.
VisionWeightEstimate applyWeightInterval(double weightKg, double marginKg, double targetCoverage) {
  if (!marginKg.isFinite || marginKg < 0 || !targetCoverage.isFinite || targetCoverage <= 0 || targetCoverage >= 1) {
    throw const FormatException('Invalid calibrated margin');
  }
  return VisionWeightEstimate(
    weightKg: weightKg,
    lowerKg: math.max(0, weightKg - marginKg),
    upperKg: weightKg + marginKg,
    targetCoverage: targetCoverage,
  );
}

/// Reproduce el preprocesamiento MobileNetV2 usado durante el entrenamiento.
/// El buffer plano evita construir miles de listas Dart durante cada inferencia.
Float32List prepareWeightInput(Uint8List jpegBytes) {
  final decoded = img.decodeImage(jpegBytes);
  if (decoded == null) throw const FormatException('Invalid image for inference');
  final resized = img.copyResize(
    img.bakeOrientation(decoded),
    width: 224,
    height: 224,
    interpolation: img.Interpolation.linear,
  );
  final input = Float32List(224 * 224 * 3);
  var index = 0;
  for (final pixel in resized) {
    input[index++] = pixel.r / 127.5 - 1;
    input[index++] = pixel.g / 127.5 - 1;
    input[index++] = pixel.b / 127.5 - 1;
  }
  return input;
}
