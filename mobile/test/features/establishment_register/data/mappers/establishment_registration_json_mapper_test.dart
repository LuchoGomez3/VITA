import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/establishment_register/data/mappers/establishment_registration_json_mapper.dart';
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
    cantidadVertices: 7,
  );

  group('EstablishmentRegistrationJsonMapper.toJson', () {
    test('serializes every field in snake_case, without poligono', () {
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
