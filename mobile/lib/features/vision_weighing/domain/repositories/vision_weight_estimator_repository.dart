import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_weight_estimate.dart';

/// Contrato de inferencia local independiente de cualquier persistencia.
abstract interface class VisionWeightEstimatorRepository {
  /// Devuelve el peso y el intervalo calibrado para la fotografía recibida.
  Future<VisionWeightEstimate> estimateWeight(Uint8List jpegBytes);
}
