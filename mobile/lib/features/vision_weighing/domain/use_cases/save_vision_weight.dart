import 'package:frontend_mayoral/features/vision_weighing/domain/entities/reviewed_vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_repository.dart';

/// Persiste en SQLite un resultado revisado y vinculado a un animal local.
class SaveVisionWeight {
  /// La búsqueda y el guardado quedan tras el contrato de dominio.
  const SaveVisionWeight(this._repository);

  final VisionWeightRepository _repository;

  /// Persiste únicamente una captura revisada con identidad y peso válidos.
  Future<void> call({required String animalId, required ReviewedVisionCapture reviewedCapture}) {
    final weightKg = reviewedCapture.capture.estimatedWeightKg;
    if (animalId.trim().isEmpty || weightKg == null || !weightKg.isFinite || weightKg <= 0) {
      throw const InvalidVisionWeightSaveException();
    }
    return _repository.saveEstimate(animalId: animalId.trim(), weightKg: weightKg);
  }
}
