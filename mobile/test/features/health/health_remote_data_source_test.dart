import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/authenticated_backend_client.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/auth/guarded_backend_request.dart';
import 'package:frontend_mayoral/features/health/data/datasources/health_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('a delayed 401 cannot renew or resend a mutation in the next account', () async {
    final tokens = _Tokens();
    final response = Completer<http.Response>();
    final started = Completer<void>();
    var requests = 0;
    var account = 'author';
    final service = _remote(
      tokens: tokens,
      client: MockClient((request) {
        requests++;
        expect(request.method, 'PUT');
        expect(request.headers['Authorization'], 'Bearer synthetic');
        started.complete();
        return response.future;
      }),
    );
    final operation = service.submit(
      '{"id":"operation","resultado":"Sintético"}',
      () async {
        if (account != 'author') throw StateError('Session changed');
      },
      resultEventId: 'event',
    );
    final assertion = expectLater(operation, throwsStateError);
    await started.future;
    account = 'other';
    response.complete(http.Response('', 401));
    await assertion;
    expect(requests, 1);
    expect(tokens.refreshes, 0);
  });

  test('an incremental page decodes its cursor and scopes the establishment', () async {
    final service = _remote(
      tokens: _Tokens(),
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/eventos_sanitarios');
        expect(request.url.queryParameters, {'establecimiento_id': 'farm', 'cursor': 'c1'});
        return http.Response('{"success":true,"data":[],"meta":{"next_cursor":"c2","has_more":false}}', 200);
      }),
    );
    final page = await service.history('farm', 'c1', () async {});
    expect(page.cursor, 'c2');
    expect(page.events, isEmpty);
    expect(page.hasMore, isFalse);
  });
}

HealthRemoteDataSource _remote({required _Tokens tokens, required http.Client client}) => HealthRemoteDataSource(
  GuardedBackendRequest(
    baseUrl: 'http://localhost:8000',
    send: AuthenticatedBackendClient(
      tokenProvider: tokens,
      inner: client,
      onSyncResult: (_) async => fail('Guarded requests are reconciled by their own store'),
    ).sendGuarded,
  ),
);

class _Tokens implements RefreshableBackendAccessTokenProvider {
  int refreshes = 0;

  @override
  Future<String?> getAccessToken() async => 'synthetic';

  @override
  Future<String?> refreshAccessToken() async {
    refreshes++;
    return 'synthetic-refresh';
  }
}
