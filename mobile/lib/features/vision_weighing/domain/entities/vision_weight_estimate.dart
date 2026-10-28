import 'package:freezed_annotation/freezed_annotation.dart';

part 'vision_weight_estimate.freezed.dart';

/// Peso estimado y rango calibrado; la cobertura no es confianza individual.
@freezed
sealed class VisionWeightEstimate with _$VisionWeightEstimate {
  /// Conserva el resultado de inferencia sin dependencias de TFLite o JSON.
  const factory VisionWeightEstimate({
    required double weightKg,
    required double lowerKg,
    required double upperKg,
    required double targetCoverage,
  }) = _VisionWeightEstimate;
}
