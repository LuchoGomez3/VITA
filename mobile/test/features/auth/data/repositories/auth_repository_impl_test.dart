import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late _MemorySecureStorage secureStorage;

    setUp(() {
      secureStorage = _MemorySecureStorage();
    });

    tearDown(SessionBackendAccessTokenProvider.instance.clearAccessToken);

    test('signIn persists session and hydrates the Brick token provider', () async {
      final repository = _createRepository(
        secureStorage: secureStorage,
        client: MockClient((request) async {
          expect(request.url.path, '/api/auth/login');
          expect(request.bodyFields['username'], 'ernesto@example.com');

          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'access_token': 'jwt-token',
                'token_type': 'bearer',
                'usuario': _userJson,
              },
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
          expect(data.user.firstName, 'Ernesto');
        case Failure(:final error):
          fail(error.message);
      }

      expect(
        await SessionBackendAccessTokenProvider.instance.getAccessToken(),
        'jwt-token',
      );
      expect(
        await secureStorage.read(SecureStorageKeys.authSession),
        isNotNull,
      );
    });

    test('restoreSession rebuilds session from secure storage without backend', () async {
      await secureStorage.write(
        key: SecureStorageKeys.authSession,
        value: jsonEncode({
          'access_token': 'stored-token',
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
          expect(data.user.email, 'ernesto@example.com');
        case Failure(:final error):
          fail(error.message);
      }
      expect(
        await SessionBackendAccessTokenProvider.instance.getAccessToken(),
        'stored-token',
      );
    });

    test('signOut clears secure storage and memory token', () async {
      await secureStorage.write(
        key: SecureStorageKeys.authSession,
        value: 'stored-session',
      );
      SessionBackendAccessTokenProvider.instance.accessToken = 'jwt-token';
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
};

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
