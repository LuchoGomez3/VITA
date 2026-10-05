import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';

void main() {
  test('arma el pull con establecimiento y bajas logicas', () {
    final request = BrickAnimalRequestTransformer.listByEstablishmentRequest(
      'establishment id',
    );

    expect(
      request.url,
      '/api/v1/animales?establecimiento_id=establishment+id&include_deleted=true',
    );
    expect(request.topLevelKey, 'data');
  });

  group('animal backend parsing', () {
    test('normalizes nullable text fields returned by the backend', () {
      expect(brickStringFromBackend(null), isEmpty);
      expect(brickStringFromBackend('Angus'), 'Angus');
    });

    test('normalizes nullable dates returned by the backend', () {
      expect(
        brickDateTimeFromBackend(null),
        DateTime.fromMillisecondsSinceEpoch(0),
      );
    });

    test('parses optional decimal values returned as strings', () {
      expect(brickNullableDoubleFromBackend(null), isNull);
      expect(brickNullableDoubleFromBackend('185.500'), 185.5);
    });
  });
}
