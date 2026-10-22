import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';

void main() {
  final provider = SessionBackendAccessTokenProvider.instance;
  setUp(provider.clearAccessToken);
  tearDown(() {
    provider
      ..clearAccessToken()
      ..refreshCallback = null;
  });

  test('renovar JWT conserva identidad; cerrar y volver a entrar la cambia', () async {
    provider.session = _session('first');
    final generation = provider.sessionGeneration;
    provider.refreshCallback = (_) async => _session('renewed');
    expect(await provider.refreshAccessToken(), 'renewed');
    expect(provider.sessionGeneration, generation);
    provider
      ..clearAccessToken()
      ..session = _session('second-user');
    expect(provider.sessionGeneration, isNot(generation));
  });

  test('una renovación tardía no reemplaza la sesión siguiente', () async {
    provider.session = _session('first');
    final pending = Completer<BackendTokenSession?>();
    provider.refreshCallback = (_) => pending.future;
    final refreshing = provider.refreshAccessToken();
    final rejected = expectLater(refreshing, throwsA(isA<DomainException>()));
    provider
      ..clearAccessToken()
      ..session = _session('second-user');
    pending.complete(_session('stale'));
    await rejected;
    expect(provider.accessToken, 'second-user');
  });
}

BackendTokenSession _session(String token) => BackendTokenSession(
  accessToken: token,
  refreshToken: 'synthetic-refresh',
  accessTokenExpiresAt: DateTime.utc(2030),
);
