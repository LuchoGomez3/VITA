import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/establishment_register/data/mappers/establishment_registration_json_mapper.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';

void main() {
  const registration = EstablishmentRegistration(
    nombre: 'La Sirena',
    descripcion: 'Cría y recría.',
    tiposProduccion: ['Cría', 'Recría'],
    cuitTitular: '20-12345678-6',
    nroRenspa: '07.123.0.00456/01',
    provincia: 'Córdoba',
    departamento: 'Río Cuarto',
    localidad: 'Coronel Moldes',
    latitud: -33.7242,
    longitud: -64.5891,
    superficieHectareas: 847,
  );

  group('EstablishmentRegistrationJsonMapper.toJson', () {
    test('omits poligono when the surface was entered by hand', () {
      final json = EstablishmentRegistrationJsonMapper.toJson(registration);

      expect(json, {
        'nombre': 'La Sirena',
        'descripcion': 'Cría y recría.',
        'tipo_produccion': ['Cría', 'Recría'],
        'cuit': '20-12345678-6',
        'nro_renspa': '07.123.0.00456/01',
        'provincia': 'Córdoba',
        'departamento': 'Río Cuarto',
        'localidad': 'Coronel Moldes',
        'latitud': -33.7242,
        'longitud': -64.5891,
        'superficie_ha': 847.0,
      });
      expect(json.containsKey('poligono'), isFalse);
    });

    test('sends the drawn polygon with 1-based orden, in drawing order', () {
      final json = EstablishmentRegistrationJsonMapper.toJson(
        registration.copyWith(
          poligono: const [
            BoundaryPoint(latitud: -33.10, longitud: -64.10),
            BoundaryPoint(latitud: -33.10, longitud: -64.20),
            BoundaryPoint(latitud: -33.20, longitud: -64.20),
          ],
        ),
      );

      expect(json['poligono'], [
        {'orden': 1, 'latitud': -33.10, 'longitud': -64.10},
        {'orden': 2, 'latitud': -33.10, 'longitud': -64.20},
        {'orden': 3, 'latitud': -33.20, 'longitud': -64.20},
      ]);
    });

    test('rounds the surface to the 2 decimals the backend stores', () {
      final json = EstablishmentRegistrationJsonMapper.toJson(
        registration.copyWith(superficieHectareas: 312.4678),
      );

      expect(json['superficie_ha'], 312.47);
    });
  });

  group('EstablishmentRegistrationJsonMapper.registeredFromJson', () {
    test('combines the backend id/created_at with the known registration', () {
      final registered = EstablishmentRegistrationJsonMapper.registeredFromJson(
        {
          'id': 'est-123',
          'created_at': '2025-03-14T00:00:00.000Z',
          'rol': 'owner',
        },
        registration,
      );

      expect(registered.id, 'est-123');
      expect(registered.registration, registration);
      expect(registered.createdAt, DateTime.parse('2025-03-14T00:00:00.000Z'));
      expect(registered.role, UserRole.owner);
    });

    test('throws a FormatException when id or created_at are missing', () {
      expect(
        () => EstablishmentRegistrationJsonMapper.registeredFromJson(
          {'id': 'est-123'},
          registration,
        ),
        throwsFormatException,
      );
    });
  });
}
