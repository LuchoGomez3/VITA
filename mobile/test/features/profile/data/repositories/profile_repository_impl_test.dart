import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';

void main() {
  test('lee todos los datos del establecimiento guardado durante el login', () async {
    final storage = _MemorySecureStorage({
      SecureStorageKeys.establishmentCatalog: jsonEncode([
        {
          'id': 'establishment-1',
          'owner_id': 'user-1',
          'name': 'Campo Norte',
          'renspa_number': 'RENSPA-1',
          'cuit': '20-12345678-9',
          'area_hectares': 125.5,
          'province': 'Córdoba',
          'department': 'Río Cuarto',
          'locality': 'Río Cuarto',
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-07-01T00:00:00Z',
        },
      ]),
    });
    final repository = ProfileRepositoryImpl(secureStorage: storage);

    final result = await repository.getEstablishments();

    expect(result, isA<Success<List<EstablishmentDetails>>>());
    final establishment =
        (result as Success<List<EstablishmentDetails>>).data.single;
    expect(establishment.name, 'Campo Norte');
    expect(establishment.renspaNumber, 'RENSPA-1');
    expect(establishment.areaHectares, 125.5);
    expect(establishment.province, 'Córdoba');
  });
}

class _MemorySecureStorage implements SecureStorageService {
  _MemorySecureStorage(this.values);

  final Map<String, String> values;

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String value,
  }) async {
    values[key] = value;
  }
}
