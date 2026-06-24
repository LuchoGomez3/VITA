import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/authenticated_backend_client.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthenticatedBackendClient', () {
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
