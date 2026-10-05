/// Contrato para persistir un pesaje estimado ya validado.
abstract interface class VisionWeightRepository {
  /// Guarda el peso con la identidad local seleccionada por el operario.
  Future<void> saveEstimate({required String animalId, required double weightKg});
}
