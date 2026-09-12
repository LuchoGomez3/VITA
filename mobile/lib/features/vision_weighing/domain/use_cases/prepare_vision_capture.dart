import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_capture_repository.dart';

/// Coordina el control obligatorio previo a revisar una captura lateral.
class PrepareVisionCapture {
  /// Recibe el contrato de procesamiento local.
  const PrepareVisionCapture(this._repository);

  final VisionCaptureRepository _repository;

  /// No habilita inferencia: una foto nítida todavía requiere revisar el perfil.
  Future<VisionCapture> call(Uint8List bytes) => _repository.prepare(bytes);
}

/// Interpreta kilos ingresados en campo, aceptando coma o punto decimal.
///
/// No acepta separadores de miles: evita que «1.200» se interprete como 1200 kg
/// cuando el operario podría haber querido ingresar 1,2 kg.
double? parseCalibrationWeight(String input) {
  final normalized = input.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(normalized)) return null;
  final weight = double.tryParse(normalized);
  return weight != null && weight.isFinite && weight > 0 ? weight : null;
}
