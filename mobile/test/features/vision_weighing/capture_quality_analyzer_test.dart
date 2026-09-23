import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/services/capture_quality_analyzer.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_capture.dart';
import 'package:image/image.dart' as img;

/// Patrón sintético distribuido: permite medir desenfoque sin datos de campo.
img.Image sharpImage({int width = 960, int height = 540}) {
  final image = img.Image(width: width, height: height);
  for (final pixel in image) {
    final value = ((pixel.x ~/ 12 + pixel.y ~/ 12) % 2) == 0 ? 65 : 190;
    pixel.setRgb(value, value, value);
  }
  return image;
}

Uint8List encode(img.Image image) => Uint8List.fromList(img.encodeJpg(image));

void main() {
  test('foto nítida horizontal exige revisión humana, nunca reconoce perfil', () {
    final result = analyzeCapture(encode(sharpImage()));
    expect(result.quality, CaptureQuality.reviewRequired);
    expect(img.decodeJpg(result.jpegBytes), isNotNull);
  });

  test('desenfoque sintético queda marcado para revisión manual', () {
    final blurred = img.gaussianBlur(sharpImage(), radius: 18);
    expect(analyzeCapture(encode(blurred)).quality, CaptureQuality.blurry);
  });

  test('detalle sólo de un lado se deriva a revisión manual', () {
    final image = sharpImage();
    for (final pixel in image) {
      if (pixel.x > image.width ~/ 3) pixel.setRgb(125, 125, 125);
    }
    expect(analyzeCapture(encode(image)).quality, CaptureQuality.reviewRequired);
  });

  test('un JPEG vertical no determina el perfil del animal', () {
    final result = analyzeCapture(encode(sharpImage(width: 540, height: 960)));

    expect(result.quality, CaptureQuality.reviewRequired);
  });

  test('resolución insuficiente rechaza en ambas orientaciones', () {
    expect(
      analyzeCapture(encode(sharpImage(width: 320, height: 180))).quality,
      CaptureQuality.insufficientResolution,
    );
    expect(
      analyzeCapture(encode(sharpImage(width: 180, height: 320))).quality,
      CaptureQuality.insufficientResolution,
    );
  });

  test('luz insuficiente y saturación tienen diagnóstico específico', () {
    for (final value in [0, 255]) {
      final image = img.Image(width: 960, height: 540);
      img.fill(image, color: img.ColorRgb8(value, value, value));
      expect(analyzeCapture(encode(image)).quality, CaptureQuality.badExposure);
    }
  });

  test('bytes corruptos producen error recuperable', () {
    expect(() => analyzeCapture(Uint8List.fromList([1, 2, 3])), throwsFormatException);
  });
}
