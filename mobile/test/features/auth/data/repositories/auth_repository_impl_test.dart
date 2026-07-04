import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthRepositoryImpl', () {
    tearDown(SessionBackendAccessTokenProvider.instance.clearAccessToken);

    test('signIn stores backend token and returns authenticated user', () async {
      final repository = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSource(
          backendBaseUrl: _backendBaseUrl,
          client: MockClient((request) async {
            if (request.url.path == '/api/auth/login') {
              return http.Response(
                jsonEncode({
                  'success': true,
                  'data': {
                    'access_token': 'jwt-token',
                    'token_type': 'bearer',
                  },
                }),
                200,
              );
            }

            expect(request.headers['Authorization'], 'Bearer jwt-token');
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'id': '55c15f56-9f1c-4efd-8808-d2a31a5ddbb4',
                  'nombre': 'Ernesto',
                  'apellido': 'Diaz',
                  'email': 'ernesto@example.com',
                },
              }),
              200,
            );
          }),
        ),
        tokenProvider: SessionBackendAccessTokenProvider.instance,
      );

      final result = await repository.signIn(
        username: 'ernesto@example.com',
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
    });

    test('signIn maps unauthorized backend response', () async {
      final repository = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSource(
          backendBaseUrl: _backendBaseUrl,
          client: MockClient((request) async {
            return http.Response(
              jsonEncode({
                'detail': 'Incorrect username or password',
              }),
              401,
            );
          }),
        ),
        tokenProvider: SessionBackendAccessTokenProvider.instance,
      );

      final result = await repository.signIn(
        username: 'ernesto@example.com',
        password: 'wrong',
      );

      switch (result) {
        case Success():
          fail('Expected unauthorized failure.');
        case Failure(:final error):
          expect(error.code, DomainErrorCode.unauthorized);
          expect(error.message, 'Usuario o contraseña incorrectos.');
      }
    });
  });
}

const _backendBaseUrl = 'http://localhost:8000';
