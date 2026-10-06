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

    test('maps every productive status and fails closed for unknown values', () {
      expect(
        brickAnimalProductiveStatusFromBackend('activo'),
        BrickAnimalProductiveStatus.active,
      );
      expect(
        brickAnimalProductiveStatusFromBackend('vendido'),
        BrickAnimalProductiveStatus.sold,
      );
      expect(
        brickAnimalProductiveStatusFromBackend('muerto'),
        BrickAnimalProductiveStatus.dead,
      );
      expect(
        brickAnimalProductiveStatusFromBackend('baja'),
        BrickAnimalProductiveStatus.removed,
      );
      expect(
        brickAnimalProductiveStatusFromBackend('future_status'),
        BrickAnimalProductiveStatus.unknown,
      );
      expect(
        brickAnimalProductiveStatusFromBackend(null),
        BrickAnimalProductiveStatus.unknown,
      );
    });

    test('treats missing legacy SQLite values as active', () {
      expect(
        brickAnimalProductiveStatusFromSqlite(null),
        BrickAnimalProductiveStatus.active,
      );
    });

    test('fails closed for invalid SQLite values', () {
      expect(
        brickAnimalProductiveStatusFromSqlite('invalid'),
        BrickAnimalProductiveStatus.unknown,
      );
      expect(
        brickAnimalProductiveStatusFromSqlite('sold'),
        BrickAnimalProductiveStatus.sold,
      );
    });
  });
}
