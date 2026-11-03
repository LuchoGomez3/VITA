import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/sync/data/models/establishment_remote_summary.dart';

void main() {
  test('parses and serializes the establishment membership role', () {
    final establishment = EstablishmentRemoteSummary.fromJson({
      ..._baseJson,
      'rol': 'admin',
    });

    expect(establishment.role, UserRole.admin);
    expect(establishment.toJson()['role'], 'admin');
  });

  test('maps missing or invalid roles to unknown without throwing', () {
    expect(
      EstablishmentRemoteSummary.fromJson(_baseJson).role,
      UserRole.unknown,
    );
    expect(
      EstablishmentRemoteSummary.fromJson({
        ..._baseJson,
        'rol': 42,
      }).role,
      UserRole.unknown,
    );
  });

  test('guarda la ubicación y el contorno en el orden del backend', () {
    final establishment = EstablishmentRemoteSummary.fromJson({
      ..._baseJson,
      'latitud': '-33.123198',
      'longitud': -64.349298,
      'poligono': [
        {'orden': 2, 'latitud': -33.12, 'longitud': -64.34},
        {'orden': 0, 'latitud': -33.10, 'longitud': -64.36},
        {'orden': 1, 'latitud': '-33.11', 'longitud': '-64.35'},
      ],
    });

    expect(establishment.latitude, -33.123198);
    expect(establishment.longitude, -64.349298);
    expect(establishment.boundary, [
      (latitude: -33.10, longitude: -64.36),
      (latitude: -33.11, longitude: -64.35),
      (latitude: -33.12, longitude: -64.34),
    ]);
    expect(establishment.toJson()['boundary'], [
      {'latitude': -33.10, 'longitude': -64.36},
      {'latitude': -33.11, 'longitude': -64.35},
      {'latitude': -33.12, 'longitude': -64.34},
    ]);
  });

  test('descarta el contorno entero si un vértice viene incompleto', () {
    final establishment = EstablishmentRemoteSummary.fromJson({
      ..._baseJson,
      'poligono': [
        {'orden': 0, 'latitud': -33.10, 'longitud': -64.36},
        {'orden': 1, 'latitud': null, 'longitud': -64.35},
        {'orden': 2, 'latitud': -33.12, 'longitud': -64.34},
      ],
    });

    expect(establishment.boundary, isEmpty);
  });

  test('sin ubicación ni contorno deja los campos vacíos', () {
    final establishment = EstablishmentRemoteSummary.fromJson(_baseJson);

    expect(establishment.latitude, isNull);
    expect(establishment.longitude, isNull);
    expect(establishment.boundary, isEmpty);
  });
}

const _baseJson = <String, Object?>{
  'id': 'establishment-id',
  'owner_id': 'owner-id',
  'nombre': 'Campo Norte',
  'created_at': '2026-08-27T10:00:00.000Z',
  'updated_at': '2026-08-27T10:00:00.000Z',
};
