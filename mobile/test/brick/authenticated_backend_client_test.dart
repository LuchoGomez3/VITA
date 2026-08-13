import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/authenticated_backend_client.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthenticatedBackendClient', () {
    tearDown(() {
      SessionBackendAccessTokenProvider.instance
        ..refreshCallback = null
        ..clearAccessToken();
    });

    test('adds the bearer token to backend requests', () async {
      final client = AuthenticatedBackendClient(
        tokenProvider: const _FakeTokenProvider('jwt-token'),
        onSyncResult: (_) async {},
        inner: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer jwt-token');
          return http.Response(_successBody, 201);
        }),
      );

      await client.post(
        Uri.parse('http://localhost:8000/api/v1/animales'),
        body: jsonEncode(_requestBody),
      );
    });

    test('reports synchronized resources after a successful backend response', () async {
      final results = <BackendSyncResult>[];
      final client = AuthenticatedBackendClient(
        tokenProvider: const _FakeTokenProvider('jwt-token'),
        onSyncResult: (result) async => results.add(result),
        inner: MockClient((request) async {
          return http.Response(_successBody, 201);
        }),
      );

      await client.post(
        Uri.parse('http://localhost:8000/api/v1/animales'),
        body: jsonEncode(_requestBody),
      );

      expect(results.single.localId, _requestBody['id']);
      expect(results.single.resourcePath, '/api/v1/animales');
      expect(results.single.synchronized, isTrue);
      expect(results.single.errorCode, isNull);
    });

    test('reports functional backend errors as rejected sync results', () async {
      final results = <BackendSyncResult>[];
      final client = AuthenticatedBackendClient(
        tokenProvider: const _FakeTokenProvider('jwt-token'),
        onSyncResult: (result) async => results.add(result),
        inner: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'errors': [
                {'code': 'caravana_duplicada', 'message': 'Duplicada'},
              ],
            }),
            409,
          );
        }),
      );

      await client.post(
        Uri.parse('http://localhost:8000/api/v1/animales'),
        body: jsonEncode(_requestBody),
      );

      expect(results.single.localId, _requestBody['id']);
      expect(results.single.synchronized, isFalse);
      expect(results.single.errorCode, 'caravana_duplicada');
    });

    test('does not report server errors so Brick can retry them', () async {
      final results = <BackendSyncResult>[];
      final client = AuthenticatedBackendClient(
        tokenProvider: const _FakeTokenProvider('jwt-token'),
        onSyncResult: (result) async => results.add(result),
        inner: MockClient((request) async {
          return http.Response('server error', 500);
        }),
      );

      await client.post(
        Uri.parse('http://localhost:8000/api/v1/animales'),
        body: jsonEncode(_requestBody),
      );

      expect(results, isEmpty);
    });

    test('uses a fresh token from the session provider', () async {
      SessionBackendAccessTokenProvider.instance.session = BackendTokenSession(
        accessToken: 'fresh-token',
        refreshToken: 'refresh-token',
        accessTokenExpiresAt: DateTime.now().toUtc().add(
          const Duration(hours: 1),
        ),
      );
      final client = AuthenticatedBackendClient(
        tokenProvider: SessionBackendAccessTokenProvider.instance,
        onSyncResult: (_) async {},
        inner: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer fresh-token');
          return http.Response(_successBody, 201);
        }),
      );

      await client.post(
        Uri.parse('http://localhost:8000/api/v1/animales'),
        body: jsonEncode(_requestBody),
      );
    });

    test('refreshes an expired token before sending the request', () async {
      SessionBackendAccessTokenProvider.instance
        ..session = BackendTokenSession(
          accessToken: 'expired-token',
          refreshToken: 'refresh-token',
          accessTokenExpiresAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 1),
          ),
        )
        ..refreshCallback = (refreshToken) async {
          expect(refreshToken, 'refresh-token');
          return BackendTokenSession(
            accessToken: 'renewed-token',
            refreshToken: 'renewed-refresh-token',
            accessTokenExpiresAt: DateTime.now().toUtc().add(
              const Duration(hours: 1),
            ),
          );
        };
      final client = AuthenticatedBackendClient(
        tokenProvider: SessionBackendAccessTokenProvider.instance,
        onSyncResult: (_) async {},
        inner: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer renewed-token');
          return http.Response(_successBody, 201);
        }),
      );

      await client.post(
        Uri.parse('http://localhost:8000/api/v1/animales'),
        body: jsonEncode(_requestBody),
      );
    });

    test('returns a transient response when refresh fails offline', () async {
      SessionBackendAccessTokenProvider.instance
        ..session = BackendTokenSession(
          accessToken: 'expired-token',
          refreshToken: 'refresh-token',
          accessTokenExpiresAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 1),
          ),
        )
        ..refreshCallback = (_) async => null;
      final client = AuthenticatedBackendClient(
        tokenProvider: SessionBackendAccessTokenProvider.instance,
        onSyncResult: (_) async {},
        inner: MockClient((request) async {
          fail('Request should not be sent with an expired token.');
        }),
      );

      final response = await client.post(
        Uri.parse('http://localhost:8000/api/v1/animales'),
        body: jsonEncode(_requestBody),
      );

      expect(response.statusCode, 503);
    });

    test('returns 401 and reports auth rejection when refresh is unauthorized', () async {
      final results = <BackendSyncResult>[];
      SessionBackendAccessTokenProvider.instance
        ..session = BackendTokenSession(
          accessToken: 'expired-token',
          refreshToken: 'refresh-token',
          accessTokenExpiresAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 1),
          ),
        )
        ..refreshCallback = (_) async {
          throw const DomainException(
            message: 'La sesion expiro.',
            code: DomainErrorCode.unauthorized,
          );
        };

      final client = AuthenticatedBackendClient(
        tokenProvider: SessionBackendAccessTokenProvider.instance,
        onSyncResult: (result) async => results.add(result),
        inner: MockClient((request) async {
          fail('Request should not reach the backend when refresh is unauthorized.');
        }),
      );

      final response = await client.post(
        Uri.parse('http://localhost:8000/api/v1/animales'),
        body: jsonEncode(_requestBody),
      );

      expect(response.statusCode, 401);
      expect(results.single.localId, _requestBody['id']);
      expect(results.single.synchronized, isFalse);
      expect(results.single.errorCode, 'auth_error');
      expect(SessionBackendAccessTokenProvider.instance.accessToken, isNull);
    });

    test('notifies auth rejection when backend returns 401', () async {
      var rejectionCount = 0;
      final client = AuthenticatedBackendClient(
        tokenProvider: const _FakeTokenProvider('jwt-token'),
        onSyncResult: (_) async {},
        onUnauthorized: () async => rejectionCount++,
        inner: MockClient((_) async => http.Response('unauthorized', 401)),
      );

      final response = await client.get(
        Uri.parse('http://localhost:8000/api/v1/categorias'),
      );

      expect(response.statusCode, 401);
      expect(rejectionCount, 1);
    });

    test('does not reject auth for non-401 backend errors', () async {
      var rejectionCount = 0;
      final client = AuthenticatedBackendClient(
        tokenProvider: const _FakeTokenProvider('jwt-token'),
        onSyncResult: (_) async {},
        onUnauthorized: () async => rejectionCount++,
        inner: MockClient((_) async => http.Response('server error', 503)),
      );

      final response = await client.get(
        Uri.parse('http://localhost:8000/api/v1/categorias'),
      );

      expect(response.statusCode, 503);
      expect(rejectionCount, 0);
    });
  });
}

const _requestBody = <String, Object?>{
  'id': '5b1f1111-1111-4111-8111-111111111111',
  'nro_caravana_rfid': '982000412991416',
};

final String _successBody = jsonEncode({
  'success': true,
  'data': {
    'id': _requestBody['id'],
    'nro_caravana_rfid': _requestBody['nro_caravana_rfid'],
  },
});

class _FakeTokenProvider implements BackendAccessTokenProvider {
  const _FakeTokenProvider(this.token);

  final String? token;

  @override
  Future<String?> getAccessToken() async => token;
}
