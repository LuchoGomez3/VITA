import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal_location.freezed.dart';

/// Ubicación local actual, independiente de fotos, pesajes y conectividad.
@freezed
sealed class AnimalLocation with _$AnimalLocation {
  /// Identifica el animal y el establecimiento al que pertenece la ubicación.
  const factory AnimalLocation({
    required String animalId,
    required String establishmentId,
    required String lotId,
    required String lotName,
    required DateTime updatedAt,
  }) = _AnimalLocation;
}
