import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_weight_estimate.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_estimator_repository.dart';

/// Ejecuta una predicción offline y rechaza resultados no utilizables.
class EstimateVisionWeight {
  /// Recibe un puerto para mantener TFLite fuera del dominio.
  const EstimateVisionWeight(this._repository);

  final VisionWeightEstimatorRepository _repository;

  /// Valida también el intervalo antes de ofrecerlo en la revisión visual.
  Future<VisionWeightEstimate> call(Uint8List jpegBytes) async {
    final estimate = await _repository.estimateWeight(jpegBytes);
    if (!estimate.weightKg.isFinite ||
        estimate.weightKg <= 0 ||
        !estimate.lowerKg.isFinite ||
        !estimate.upperKg.isFinite ||
        estimate.lowerKg < 0 ||
        estimate.lowerKg > estimate.weightKg ||
        estimate.upperKg < estimate.weightKg ||
        !estimate.targetCoverage.isFinite ||
        estimate.targetCoverage <= 0 ||
        estimate.targetCoverage >= 1) {
      throw const InvalidVisionWeightEstimateException();
    }
    return estimate;
  }
}
