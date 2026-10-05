import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_satellite_layer.dart';

void main() {
  test('el fondo sólo corresponde al nombre exacto San Nicolás', () {
    for (final name in ['San Nicolás', 'san nicolas', ' SAN NICOLÁS ']) {
      expect(FieldSatelliteMap.supportsEstablishment(name), isTrue);
    }
    for (final name in [null, '', 'La Sirena', 'San Nicolás Norte', 'Otro San Nicolás']) {
      expect(FieldSatelliteMap.supportsEstablishment(name), isFalse);
    }
  });

  test('la imagen mantiene su proporción original dentro del lienzo local', () {
    final bounds = FieldSatelliteMap.bounds;
    expect((bounds.east - bounds.west) / (bounds.north - bounds.south), closeTo(5052 / 2846, 0.00001));
    expect(bounds.south, greaterThanOrEqualTo(0));
    expect(bounds.north, lessThanOrEqualTo(80));
  });
}
