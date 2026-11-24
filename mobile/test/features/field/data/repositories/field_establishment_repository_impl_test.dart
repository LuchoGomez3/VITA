import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/field/data/repositories/field_establishment_repository_impl.dart';

void main() {
  test('el mapa usa las coordenadas del establecimiento elegido en el catálogo offline', () async {
    final storage = _SecureStorage({
      SecureStorageKeys.establishmentCatalog: jsonEncode([
        {'id': 'legacy', 'name': 'Catálogo anterior'},
        {'id': 'other', 'name': 'Otro campo', 'latitude': -32, 'longitude': -63},
        {
          'id': 'field',
          'name': 'Campo',
          'latitude': -33.1,
          'longitude': -64.3,
          'boundary': [
            {'latitude': -33.10, 'longitude': -64.36},
            {'latitude': -33.11, 'longitude': -64.35},
            {'latitude': -33.12, 'longitude': -64.34},
          ],
        },
      ]),
    });
    final repository = FieldEstablishmentRepositoryImpl(storage);

    final location = await repository.getMapLocation('field');
    expect(location?.center, (latitude: -33.1, longitude: -64.3));
    expect(location?.boundary, hasLength(3));
    expect(location?.boundary.last, (latitude: -33.12, longitude: -64.34));
    expect(await repository.getMapLocation('legacy'), isNull);
    expect(await repository.getMapLocation('missing'), isNull);
  });
}

class _SecureStorage implements SecureStorageService {
  _SecureStorage(this.values);

  final Map<String, String> values;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async => values[key] = value;
}
