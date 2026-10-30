import 'dart:typed_data';

/// Contrato para persistir un pesaje estimado ya validado.
abstract interface class VisionWeightRepository {
  /// Guarda el peso y la foto privada con la identidad seleccionada.
  /// Revalida la membresía offline antes de producir efectos persistentes.
  Future<void> saveEstimate({required String animalId, required double weightKg, required Uint8List jpegBytes});
}
