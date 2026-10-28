import 'dart:typed_data';

import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:image/image.dart' as img;

/// Evalúa calidad sobre una escala fija para comparar cámaras de distinta
/// resolución. Los umbrales son iniciales y deben ajustarse con fotos de manga.
///
/// La varianza del Laplaciano mide cambios locales de intensidad: el desenfoque
/// los suaviza. Se mide el centro de la guía para que una manga nítida en los
/// bordes no oculte un sujeto borroso. El resultado de nitidez es orientativo
/// hasta calibrar el umbral con capturas reales y requiere revisión humana.
VisionCapture analyzeCapture(Uint8List bytes) {
  // Algunos codecs lanzan RangeError con cabeceras truncadas. Se transforma
  // aquí en un error de formato recuperable, sin ocultar errores de la UI.
  final img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
    // El codec usa Error para entradas externas truncadas (cubierto por test).
    // ignore: avoid_catching_errors
  } on RangeError {
    throw const FormatException('Truncated capture image');
  }
  if (decoded == null) throw const FormatException('Invalid capture image');
  final oriented = img.bakeOrientation(decoded);
  final longSide = oriented.width > oriented.height ? oriented.width : oriented.height;
  final shortSide = oriented.width < oriented.height ? oriented.width : oriented.height;
  if (longSide < 640 || shortSide < 360) {
    return VisionCapture(
      jpegBytes: bytes.asUnmodifiableView(),
      quality: CaptureQuality.insufficientResolution,
      sharpness: 0,
    );
  }
  // Las dimensiones del archivo no indican si el animal está de perfil.
  // La cámara puede guardar una foto vertical aunque el celular esté horizontal;
  // el perfil y el encuadre se confirman en la revisión manual.
  final sample = img.copyResize(oriented, width: 320);
  final gray = img.grayscale(sample);
  var sum = 0.0;
  var squaredSum = 0.0;
  var luminance = 0.0;
  var count = 0;
  for (var y = (gray.height * .25).round(); y < gray.height * .7; y++) {
    for (var x = 32; x < 288; x++) {
      final center = gray.getPixel(x, y).r.toDouble();
      final laplacian =
          gray.getPixel(x - 1, y).r +
          gray.getPixel(x + 1, y).r +
          gray.getPixel(x, y - 1).r +
          gray.getPixel(x, y + 1).r -
          4 * center;
      sum += laplacian;
      squaredSum += laplacian * laplacian;
      luminance += center;
      count++;
    }
  }
  final variance = count == 0 ? 0.0 : squaredSum / count - (sum / count) * (sum / count);
  final mean = count == 0 ? 0 : luminance / count;
  final quality = switch (oriented) {
    _ when mean < 30 || mean > 230 => CaptureQuality.badExposure,
    _ when variance < 85 => CaptureQuality.blurry,
    _ => CaptureQuality.reviewRequired,
  };
  // Se conserva todo el encuadre; no se recorta al animal sin un detector.
  final normalized = oriented.width > 1600 ? img.copyResize(oriented, width: 1600) : oriented;
  return VisionCapture(
    jpegBytes: Uint8List.fromList(img.encodeJpg(normalized, quality: 90)).asUnmodifiableView(),
    quality: quality,
    sharpness: variance,
  );
}
