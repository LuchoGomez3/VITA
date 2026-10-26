import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_weight_estimate.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_estimator_repository.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Carga exclusivamente recursos locales, sin descargar modelos al capturar.
class TfliteWeightEstimator implements VisionWeightEstimatorRepository {
  /// Permite probar assets ausentes sin inicializar bibliotecas nativas.
  TfliteWeightEstimator({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  static const _asset = 'assets/models/peso_bovino_mobilenet_v2.tflite';
  static const _calibrationAsset = 'assets/models/peso_bovino_intervalo.json';

  @override
  Future<VisionWeightEstimate> estimateWeight(Uint8List jpegBytes) async {
    final ByteData model;
    final ({double marginKg, double targetCoverage}) calibration;
    try {
      model = await _bundle.load(_asset);
      calibration = parseWeightCalibration(await _bundle.loadString(_calibrationAsset));
    } on Object catch (error, stack) {
      developer.log('Modelo local no disponible', name: 'vision_weighing', error: error, stackTrace: stack);
      throw VisionModelUnavailableException(cause: error);
    }
    return compute(_runWeightInference, (
      jpegBytes: jpegBytes,
      model: model.buffer.asUint8List(model.offsetInBytes, model.lengthInBytes),
      marginKg: calibration.marginKg,
      targetCoverage: calibration.targetCoverage,
    ));
  }
}

typedef _InferenceInput = ({Uint8List jpegBytes, Uint8List model, double marginKg, double targetCoverage});

// El isolate posee el codec y los recursos nativos hasta liberar el modelo.
VisionWeightEstimate _runWeightInference(_InferenceInput request) {
  final input = prepareWeightInput(request.jpegBytes);
  final Interpreter interpreter;
  try {
    interpreter = Interpreter.fromBuffer(request.model);
  } on Object catch (error) {
    throw VisionModelUnavailableException(cause: error.toString());
  }
  try {
    final inputs = interpreter.getInputTensors();
    final outputs = interpreter.getOutputTensors();
    if (inputs.length != 1 ||
        outputs.length != 1 ||
        !listEquals(inputs.single.shape, [1, 224, 224, 3]) ||
        !listEquals(outputs.single.shape, [1, 1]) ||
        inputs.single.type != TensorType.float32 ||
        outputs.single.type != TensorType.float32) {
      throw const VisionModelUnavailableException();
    }
    final output = <List<double>>[
      [0],
    ];
    interpreter.run(input.buffer, output);
    return applyWeightInterval(output.single.single, request.marginKg, request.targetCoverage);
  } finally {
    interpreter.close();
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
