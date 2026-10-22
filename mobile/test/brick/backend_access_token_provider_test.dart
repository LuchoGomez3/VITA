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

  for (final forced in [false, true]) {
    test('un refresh rechazado publica una sola invalidación (forzado: $forced)', () async {
      provider.session = BackendTokenSession(
        accessToken: 'expired',
        refreshToken: 'revoked',
        accessTokenExpiresAt: DateTime.utc(2000),
      );
      final generation = provider.sessionGeneration;
      var rejections = 0;
      final subscription = provider.authRejections.listen((_) => rejections++);
      addTearDown(subscription.cancel);
      final pending = Completer<BackendTokenSession?>();
      provider.refreshCallback = (_) => pending.future;
      Future<String?> refresh() => forced ? provider.refreshAccessToken() : provider.getAccessToken();
      final first = expectLater(refresh(), throwsA(isA<DomainException>()));
      final second = expectLater(refresh(), throwsA(isA<DomainException>()));
      pending.completeError(const DomainException(message: 'Revoked', code: DomainErrorCode.unauthorized));
      await Future.wait([first, second]);
      expect(rejections, 1);
      expect(provider.accessToken, isNull);
      expect(provider.sessionGeneration, isNot(generation));
    });
  }

  test('un rechazo tardío no invalida la identidad siguiente', () async {
    provider.session = _session('first');
    var rejections = 0;
    final subscription = provider.authRejections.listen((_) => rejections++);
    addTearDown(subscription.cancel);
    final pending = Completer<BackendTokenSession?>();
    provider.refreshCallback = (_) => pending.future;
    final rejected = expectLater(provider.refreshAccessToken(), throwsA(isA<DomainException>()));
    provider.startSession(_session('second-user'));
    pending.completeError(const DomainException(message: 'Revoked', code: DomainErrorCode.unauthorized));
    await rejected;
    expect(rejections, 0);
    expect(provider.accessToken, 'second-user');
  });

  test('una falla de red conserva la sesión offline y no publica rechazo', () async {
    provider.session = _session('offline-user');
    final generation = provider.sessionGeneration;
    var rejections = 0;
    final subscription = provider.authRejections.listen((_) => rejections++);
    addTearDown(subscription.cancel);
    provider.refreshCallback = (_) async => null;
    await expectLater(provider.refreshAccessToken(), throwsA(isA<DomainException>()));
    expect(rejections, 0);
    expect(provider.accessToken, 'offline-user');
    expect(provider.sessionGeneration, generation);
  });

  test('una sesión vencida sin renovación disponible también publica rechazo', () async {
    provider.session = BackendTokenSession(
      accessToken: 'expired',
      refreshToken: '',
      accessTokenExpiresAt: DateTime.utc(2000),
    );
    var rejections = 0;
    final subscription = provider.authRejections.listen((_) => rejections++);
    addTearDown(subscription.cancel);
    await expectLater(provider.getAccessToken(), throwsA(isA<DomainException>()));
    expect(rejections, 1);
    expect(provider.session, isNull);
  });
}

BackendTokenSession _session(String token) => BackendTokenSession(
  accessToken: token,
  refreshToken: 'synthetic-refresh',
  accessTokenExpiresAt: DateTime.utc(2030),
);
