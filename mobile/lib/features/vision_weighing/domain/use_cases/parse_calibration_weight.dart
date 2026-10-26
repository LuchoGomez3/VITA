/// Interpreta kilos ingresados en campo, aceptando coma o punto decimal.
double? parseCalibrationWeight(String input) {
  final normalized = input.trim().replaceAll(',', '.');
  // No se admiten separadores de miles para evitar entradas ambiguas como 1.200.
  if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(normalized)) return null;
  final weight = double.tryParse(normalized);
  return weight != null && weight.isFinite && weight > 0 ? weight : null;
}
