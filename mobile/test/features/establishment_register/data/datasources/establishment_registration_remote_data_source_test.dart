import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/establishment_register/data/datasources/establishment_registration_remote_data_source.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('EstablishmentRegistrationRemoteDataSource', () {
    test('posts the registration with a Bearer token and returns the created data', () async {
      final dataSource = EstablishmentRegistrationRemoteDataSource(
        backendBaseUrl: _backendBaseUrl,
        tokenProvider: const _FakeTokenProvider('access-token'),
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/establecimientos');
          expect(request.headers['Authorization'], 'Bearer access-token');
          expect(jsonDecode(request.body), {
            'nombre': 'La Sirena',
            'descripcion': 'Cría y recría.',
            'tipo_produccion': ['Cría'],
            'cuit': '20-12345678-6',
            'nro_renspa': '07.123.0.00456/01',
            'provincia': 'Córdoba',
            'departamento': 'Río Cuarto',
            'localidad': 'Coronel Moldes',
            'latitud': -33.1,
            'longitud': -64.1,
            'superficie_ha': 847.0,
          });

          return http.Response(
            jsonEncode({
              'success': true,
              'data': _establecimientoJson,
            }),
            201,
          );
        }),
      );

      final json = await dataSource.register(_registration);

      expect(json, _establecimientoJson);
    });

    test('throws unauthorized when there is no access token', () async {
      final dataSource = EstablishmentRegistrationRemoteDataSource(
        backendBaseUrl: _backendBaseUrl,
        tokenProvider: const _FakeTokenProvider(null),
        client: MockClient((request) async {
          fail('Must not call the backend without a token.');
        }),
      );

      expect(
        dataSource.register(_registration),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.unauthorized,
          ),
        ),
      );
    });

    test('maps a renspa_duplicado backend error to conflict', () async {
      final dataSource = EstablishmentRegistrationRemoteDataSource(
        backendBaseUrl: _backendBaseUrl,
        tokenProvider: const _FakeTokenProvider('access-token'),
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'errors': [
                {
                  'code': 'renspa_duplicado',
                  'message': "El RENSPA '07.123.0.00456/01' ya está registrado",
                },
              ],
            }),
            409,
          );
        }),
      );

      expect(
        dataSource.register(_registration),
        throwsA(
          isA<DomainException>()
              .having((error) => error.code, 'code', DomainErrorCode.conflict)
              .having(
                (error) => error.message,
                'message',
                "El RENSPA '07.123.0.00456/01' ya está registrado",
              ),
        ),
      );
    });

    test('maps a renspa_formato_invalido backend error to validation', () async {
      final dataSource = EstablishmentRegistrationRemoteDataSource(
        backendBaseUrl: _backendBaseUrl,
        tokenProvider: const _FakeTokenProvider('access-token'),
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'errors': [
                {
                  'code': 'renspa_formato_invalido',
                  'message': 'Formato invalido',
                },
              ],
            }),
            422,
          );
        }),
      );

      expect(
        dataSource.register(_registration),
        throwsA(
          isA<DomainException>().having(
            (error) => error.code,
            'code',
            DomainErrorCode.validation,
          ),
        ),
      );
    });
  });
}

const _backendBaseUrl = 'http://localhost:8000';

const _registration = EstablishmentRegistration(
  nombre: 'La Sirena',
  descripcion: 'Cría y recría.',
  tiposProduccion: ['Cría'],
  cuitTitular: '20-12345678-6',
  nroRenspa: '07.123.0.00456/01',
  provincia: 'Córdoba',
  departamento: 'Río Cuarto',
  localidad: 'Coronel Moldes',
  latitud: -33.1,
  longitud: -64.1,
  superficieHectareas: 847,
  cantidadVertices: 7,
);

const _establecimientoJson = <String, Object?>{
  'id': '2f6e6f0a-5a0e-4b8a-9f0a-8a9b8c8d8e8f',
  'nombre': 'La Sirena',
  'nro_renspa': '07.123.0.00456/01',
  'created_at': '2025-03-14T00:00:00Z',
};

class _FakeTokenProvider implements BackendAccessTokenProvider {
  const _FakeTokenProvider(this._token);

  final String? _token;

  @override
  Future<String?> getAccessToken() async => _token;
}
