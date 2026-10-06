import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/field_raster_geometry.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_satellite_layer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fuera de la demo el fondo corresponde al nombre exacto San Nicolás', () {
    for (final name in ['San Nicolás', 'san nicolas', ' SAN NICOLÁS ']) {
      expect(FieldSatelliteMap.supportsEstablishment(name, demoMode: false), isTrue);
    }
    for (final name in [null, '', 'La Sirena', 'San Nicolás Norte', 'Otro San Nicolás']) {
      expect(FieldSatelliteMap.supportsEstablishment(name, demoMode: false), isFalse);
    }
    expect(FieldSatelliteMap.supportsEstablishment('Establecimiento La Esperanza'), isTrue);
  });

  test('el PGW aplica escala, origen y rotación del proyecto a los píxeles', () {
    final world = RasterWorldFile.parse(File(FieldSatelliteMap.worldFilePath).readAsStringSync());
    final origin = world.pixelToProject(0, 0);
    expect(origin.x, closeTo(-6842863.04958796, 0.000001));
    expect(origin.y, closeTo(-3304632.79735, 0.000001));
    final next = world.pixelToProject(1, 0);
    expect(next.x - origin.x, closeTo(0.96745168597, 0.000001));
    expect(next.y - origin.y, closeTo(-0.17058783477, 0.000001));
  });

  test('carga los assets reales y obtiene un encuadre interior sin deformar la imagen', () async {
    final bytes = await rootBundle.load(FieldSatelliteMap.assetPath);
    final geometry = await FieldSatelliteMap.geometry;
    final width = bytes.getUint32(16);
    final height = bytes.getUint32(20);
    final topRightLongitude =
        geometry.topLeft.longitude + geometry.bottomRight.longitude - geometry.bottomLeft.longitude;
    final topRightLatitude = geometry.topLeft.latitude + geometry.bottomRight.latitude - geometry.bottomLeft.latitude;
    final horizontal = math.Point(
      topRightLongitude - geometry.topLeft.longitude,
      topRightLatitude - geometry.topLeft.latitude,
    );
    final vertical = math.Point(
      geometry.bottomLeft.longitude - geometry.topLeft.longitude,
      geometry.bottomLeft.latitude - geometry.topLeft.latitude,
    );
    expect(horizontal.magnitude / vertical.magnitude, closeTo(width / height, 0.000001));
    expect(horizontal.y, isNot(closeTo(0, 0.00001)));

    // La inversa de los ejes comprueba que cada esquina del encuadre esté
    // dentro de la fotografía, incluso con la rotación definida por el PGW.
    final determinant = horizontal.x * vertical.y - vertical.x * horizontal.y;
    final bounds = geometry.coverBounds;
    for (final corner in [
      math.Point(bounds.west, bounds.south),
      math.Point(bounds.west, bounds.north),
      math.Point(bounds.east, bounds.south),
      math.Point(bounds.east, bounds.north),
    ]) {
      final x = corner.x - geometry.topLeft.longitude;
      final y = corner.y - geometry.topLeft.latitude;
      final column = (vertical.y * x - vertical.x * y) / determinant;
      final row = (-horizontal.y * x + horizontal.x * y) / determinant;
      expect(column, inInclusiveRange(-0.000001, 1.000001));
      expect(row, inInclusiveRange(-0.000001, 1.000001));
    }
  });

  test('rechaza metadatos incompletos o una transformación sin área', () {
    expect(() => RasterWorldFile.parse('1 0 0'), throwsFormatException);
    expect(() => RasterWorldFile.parse('0 0 0 0 1 2'), throwsFormatException);
  });
}
