import 'dart:typed_data';

/// Contrato para persistir un pesaje estimado ya validado.
abstract interface class VisionWeightRepository {
  /// Guarda el peso y su foto local con la identidad seleccionada por el operario.
  Future<void> saveEstimate({required String animalId, required double weightKg, required Uint8List jpegBytes});
}
