import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';

void main() {
  test('lee la ubicación y el contorno guardados en el catálogo', () async {
    final storage = _MemoryStorage()
      ..values[SecureStorageKeys.establishmentCatalog] = jsonEncode([
        {
          ..._baseEntry,
          'latitude': -33.1,
          'longitude': -64.3,
          'boundary': [
            {'latitude': -33.10, 'longitude': -64.36},
            {'latitude': -33.11, 'longitude': -64.35},
            {'latitude': -33.12, 'longitude': -64.34},
          ],
        },
      ]);

    final result = await ProfileRepositoryImpl(secureStorage: storage).getEstablishments();

    final establishment = (result as Success<List<EstablishmentDetails>>).data.single;
    expect(establishment.latitude, -33.1);
    expect(establishment.longitude, -64.3);
    expect(establishment.boundary, hasLength(3));
    expect(establishment.boundary.first, (latitude: -33.10, longitude: -64.36));
  });

  test('un catálogo guardado antes del mapa se lee sin ubicación', () async {
    final storage = _MemoryStorage()..values[SecureStorageKeys.establishmentCatalog] = jsonEncode([_baseEntry]);

    final result = await ProfileRepositoryImpl(secureStorage: storage).getEstablishments();

    final establishment = (result as Success<List<EstablishmentDetails>>).data.single;
    expect(establishment.latitude, isNull);
    expect(establishment.longitude, isNull);
    expect(establishment.boundary, isEmpty);
    expect(establishment.areaHectares, 847);
  });
}

const _baseEntry = <String, Object?>{
  'id': 'establishment-id',
  'owner_id': 'owner-id',
  'name': 'Prueba 1',
  'role': 'owner',
  'area_hectares': 847,
  'created_at': '2026-08-27T10:00:00.000Z',
  'updated_at': '2026-08-27T10:00:00.000Z',
};

class _MemoryStorage implements SecureStorageService {
  final Map<String, String> values = {};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}
