import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late _MemorySecureStorage secureStorage;

    setUp(() {
      secureStorage = _MemorySecureStorage();
    });

    tearDown(() {
      SessionBackendAccessTokenProvider.instance
        ..refreshCallback = null
        ..clearAccessToken();
    });

    test('register returns the created user without persisting a session', () async {
      final repository = _createRepository(
        secureStorage: secureStorage,
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'usuario': _userJson,
                'access_token': 'registration-token',
                'token_type': 'bearer',
              },
            }),
            201,
          );
        }),
      );

      final result = await repository.register(
        request: const RegistrationRequest(
          firstName: 'Ernesto',
          lastName: 'Diaz',
          email: 'ernesto@example.com',
          cuit: '20-12345678-6',
          password: 'Password1',
        ),
      );

      switch (result) {
        case Success(:final data):
          expect(data.email, 'ernesto@example.com');
          expect(data.cuit, '20123456786');
        case Failure(:final error):
          fail(error.message);
      }
      expect(
        await secureStorage.read(SecureStorageKeys.authSession),
        isNull,
      );
    });

    test('signIn persists session without password and hydrates Brick', () async {
      final repository = _createRepository(
        secureStorage: secureStorage,
        client: MockClient((request) async {
          expect(request.url.path, '/api/auth/login');
          expect(request.bodyFields['username'], 'ernesto@example.com');

          return http.Response(
            jsonEncode({
              'success': true,
              'data': _sessionJson(
                accessToken: 'jwt-token',
                refreshToken: 'refresh-token',
              ),
            }),
            200,
          );
        }),
      );

      final result = await repository.signIn(
        email: 'ernesto@example.com',
        password: 'Password1',
      );

      switch (result) {
        case Success(:final data):
          expect(data.accessToken, 'jwt-token');
          expect(data.refreshToken, 'refresh-token');
          expect(data.accessTokenExpiresAt.isAfter(DateTime.now().toUtc()), isTrue);
          expect(data.user.firstName, 'Ernesto');
        case Failure(:final error):
          fail(error.message);
      }

      expect(
        await SessionBackendAccessTokenProvider.instance.getAccessToken(),
        'jwt-token',
      );
      final storedSession = await secureStorage.read(
        SecureStorageKeys.authSession,
      );
      expect(storedSession, contains('"refresh_token":"refresh-token"'));
      expect(storedSession, isNot(contains('Password1')));
    });

    test('restoreSession rebuilds expired local session without backend', () async {
      await secureStorage.write(
        key: SecureStorageKeys.authSession,
        value: jsonEncode({
          'access_token': 'stored-token',
          'refresh_token': 'stored-refresh-token',
          'access_token_expires_at': '2020-01-01T00:00:00.000Z',
          'user_id': _userJson['id'],
          'email': _userJson['email'],
          'first_name': _userJson['nombre'],
          'last_name': _userJson['apellido'],
          'role': 'unknown',
        }),
      );
      final repository = _createRepository(
        secureStorage: secureStorage,
        client: MockClient((request) async {
          fail('restoreSession must not call the backend.');
        }),
      );

      final result = await repository.restoreSession();

      switch (result) {
        case Success(:final data):
          expect(data.accessToken, 'stored-token');
          expect(data.refreshToken, 'stored-refresh-token');
          expect(data.user.email, 'ernesto@example.com');
        case Failure(:final error):
          fail(error.message);
      }
      expect(
        SessionBackendAccessTokenProvider.instance.accessToken,
        'stored-token',
      );
    });

    test('signOut clears secure storage and memory token', () async {
      await secureStorage.write(
        key: SecureStorageKeys.authSession,
        value: 'stored-session',
      );
      SessionBackendAccessTokenProvider.instance.session = BackendTokenSession(
        accessToken: 'jwt-token',
        refreshToken: 'refresh-token',
        accessTokenExpiresAt: DateTime.now().toUtc().add(
          const Duration(hours: 1),
        ),
      );
      final repository = _createRepository(
        secureStorage: secureStorage,
        client: MockClient((request) async {
          fail('signOut must not call the backend.');
        }),
      );

      await repository.signOut();

      expect(
        await secureStorage.read(SecureStorageKeys.authSession),
        isNull,
      );
      expect(
        await SessionBackendAccessTokenProvider.instance.getAccessToken(),
        isNull,
      );
    });

    test('signIn maps unauthorized backend response', () async {
      final repository = _createRepository(
        secureStorage: secureStorage,
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'detail': 'Incorrect username or password',
            }),
            401,
          );
        }),
      );

      final result = await repository.signIn(
        email: 'ernesto@example.com',
        password: 'wrong',
      );

      switch (result) {
        case Success():
          fail('Expected unauthorized failure.');
        case Failure(:final error):
          expect(error.code, DomainErrorCode.unauthorized);
          expect(error.message, 'Email o contrasena incorrectos.');
      }
    });

    test('signIn maps backend timeouts as offline failures', () async {
      final repository = _createRepository(
        secureStorage: secureStorage,
        requestTimeout: const Duration(milliseconds: 1),
        client: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return http.Response('{}', 200);
        }),
      );

      final result = await repository.signIn(
        email: 'ernesto@example.com',
        password: 'Password1',
      );

      switch (result) {
        case Success():
          fail('Expected offline failure.');
        case Failure(:final error):
          expect(error.code, DomainErrorCode.offline);
          expect(error.message, 'El backend tardo demasiado en responder.');
      }
    });

    test('refreshSession replaces stored session and memory token', () async {
      await secureStorage.write(
        key: SecureStorageKeys.authSession,
        value: jsonEncode({
          'access_token': 'old-token',
          'refresh_token': 'old-refresh-token',
          'access_token_expires_at': '2020-01-01T00:00:00.000Z',
          'user_id': _userJson['id'],
          'email': _userJson['email'],
          'first_name': _userJson['nombre'],
          'last_name': _userJson['apellido'],
          'role': 'unknown',
        }),
      );
      final repository = _createRepository(
        secureStorage: secureStorage,
        client: MockClient((request) async {
          expect(request.url.path, '/api/auth/refresh');
          expect(jsonDecode(request.body), {
            'refresh_token': 'old-refresh-token',
          });

          return http.Response(
            jsonEncode({
              'success': true,
              'data': _sessionJson(
                accessToken: 'new-token',
                refreshToken: 'new-refresh-token',
              ),
            }),
            200,
          );
        }),
      );

      final result = await repository.refreshSession();

      switch (result) {
        case Success(:final data):
          expect(data.accessToken, 'new-token');
          expect(data.refreshToken, 'new-refresh-token');
        case Failure(:final error):
          fail(error.message);
      }
      expect(
        await SessionBackendAccessTokenProvider.instance.getAccessToken(),
        'new-token',
      );
      expect(
        await secureStorage.read(SecureStorageKeys.authSession),
        contains('"refresh_token":"new-refresh-token"'),
      );
    });

    test('refreshSession uses the in-memory refresh token when provided', () async {
      await secureStorage.write(
        key: SecureStorageKeys.authSession,
        value: jsonEncode({
          'access_token': 'old-token',
          'refresh_token': 'stale-refresh-token',
          'access_token_expires_at': '2020-01-01T00:00:00.000Z',
          'user_id': _userJson['id'],
          'email': _userJson['email'],
          'first_name': _userJson['nombre'],
          'last_name': _userJson['apellido'],
          'role': 'unknown',
        }),
      );
      final repository = _createRepository(
        secureStorage: secureStorage,
        client: MockClient((request) async {
          expect(request.url.path, '/api/auth/refresh');
          expect(jsonDecode(request.body), {
            'refresh_token': 'fresh-memory-refresh-token',
          });

          return http.Response(
            jsonEncode({
              'success': true,
              'data': _sessionJson(
                accessToken: 'new-token',
                refreshToken: 'new-refresh-token',
              ),
            }),
            200,
          );
        }),
      );

      final result = await repository.refreshSession(
        refreshTokenOverride: 'fresh-memory-refresh-token',
      );

      switch (result) {
        case Success(:final data):
          expect(data.accessToken, 'new-token');
          expect(data.refreshToken, 'new-refresh-token');
        case Failure(:final error):
          fail(error.message);
      }
    });

    test('refreshSession maps unauthorized without clearing local session', () async {
      await secureStorage.write(
        key: SecureStorageKeys.authSession,
        value: jsonEncode({
          'access_token': 'old-token',
          'refresh_token': 'old-refresh-token',
          'access_token_expires_at': '2020-01-01T00:00:00.000Z',
          'user_id': _userJson['id'],
          'email': _userJson['email'],
          'first_name': _userJson['nombre'],
          'last_name': _userJson['apellido'],
          'role': 'unknown',
        }),
      );
      final repository = _createRepository(
        secureStorage: secureStorage,
        client: MockClient((request) async {
          return http.Response(jsonEncode({'detail': 'invalid refresh'}), 401);
        }),
      );

      final result = await repository.refreshSession();

      switch (result) {
        case Success():
          fail('Expected unauthorized failure.');
        case Failure(:final error):
          expect(error.code, DomainErrorCode.unauthorized);
      }
      expect(
        await secureStorage.read(SecureStorageKeys.authSession),
        isNotNull,
      );
    });

    test('refreshSession maps backend timeouts as offline failures', () async {
      await secureStorage.write(
        key: SecureStorageKeys.authSession,
        value: jsonEncode({
          'access_token': 'old-token',
          'refresh_token': 'old-refresh-token',
          'access_token_expires_at': '2020-01-01T00:00:00.000Z',
          'user_id': _userJson['id'],
          'email': _userJson['email'],
          'first_name': _userJson['nombre'],
          'last_name': _userJson['apellido'],
          'role': 'unknown',
        }),
      );
      final repository = _createRepository(
        secureStorage: secureStorage,
        requestTimeout: const Duration(milliseconds: 1),
        client: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return http.Response('{}', 200);
        }),
      );

      final result = await repository.refreshSession();

      switch (result) {
        case Success():
          fail('Expected offline failure.');
        case Failure(:final error):
          expect(error.code, DomainErrorCode.offline);
      }
    });
  });
}

AuthRepositoryImpl _createRepository({
  required SecureStorageService secureStorage,
  required http.Client client,
  Duration requestTimeout = const Duration(seconds: 10),
}) {
  return AuthRepositoryImpl(
    localDataSource: AuthLocalDataSource(secureStorage: secureStorage),
    remoteDataSource: AuthRemoteDataSource(
      backendBaseUrl: _backendBaseUrl,
      client: client,
      requestTimeout: requestTimeout,
    ),
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  );
}

const _backendBaseUrl = 'http://localhost:8000';

const _userJson = <String, Object?>{
  'id': '55c15f56-9f1c-4efd-8808-d2a31a5ddbb4',
  'nombre': 'Ernesto',
  'apellido': 'Diaz',
  'email': 'ernesto@example.com',
  'cuit': '20123456786',
};

Map<String, Object?> _sessionJson({
  required String accessToken,
  required String refreshToken,
  int expiresIn = 3600,
}) {
  return {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_in': expiresIn,
    'token_type': 'bearer',
    'usuario': _userJson,
  };
}

class _MemorySecureStorage implements SecureStorageService {
  final _values = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String value,
  }) async {
    _values[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
