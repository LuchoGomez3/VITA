import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/data/repositories/establishment_registration_repository_impl.dart';
import 'package:frontend_mayoral/features/establishment_register/data/sources/establishment_registration_remote_data_source.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('EstablishmentRegistrationRepositoryImpl', () {
    test('returns success with the registered establishment', () async {
      final repository = _createRepository(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 'est-123',
                'created_at': '2025-03-14T00:00:00.000Z',
              },
            }),
            201,
          );
        }),
      );

      final result = await repository.register(_registration);

      switch (result) {
        case Success(:final data):
          expect(data.id, 'est-123');
          expect(data.registration, _registration);
        case Failure(:final error):
          fail(error.message);
      }
    });

    test('maps a renspa_duplicado backend error to a conflict failure', () async {
      final repository = _createRepository(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'errors': [
                {'code': 'renspa_duplicado', 'message': 'RENSPA duplicado'},
              ],
            }),
            409,
          );
        }),
      );

      final result = await repository.register(_registration);

      switch (result) {
        case Success():
          fail('Expected a conflict failure.');
        case Failure(:final error):
          expect(error.code, DomainErrorCode.conflict);
      }
    });

    test('maps a connection timeout to an offline failure', () async {
      final repository = _createRepository(
        requestTimeout: const Duration(milliseconds: 1),
        client: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return http.Response('{}', 200);
        }),
      );

      final result = await repository.register(_registration);

      switch (result) {
        case Success():
          fail('Expected an offline failure.');
        case Failure(:final error):
          expect(error.code, DomainErrorCode.offline);
      }
    });
  });
}

EstablishmentRegistrationRepositoryImpl _createRepository({
  required http.Client client,
  Duration requestTimeout = const Duration(seconds: 10),
}) {
  return EstablishmentRegistrationRepositoryImpl(
    remoteDataSource: EstablishmentRegistrationRemoteDataSource(
      backendBaseUrl: 'http://localhost:8000',
      tokenProvider: const _FakeTokenProvider('access-token'),
      client: client,
      requestTimeout: requestTimeout,
    ),
  );
}

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

class _FakeTokenProvider implements BackendAccessTokenProvider {
  const _FakeTokenProvider(this._token);

  final String? _token;

  @override
  Future<String?> getAccessToken() async => _token;
}
