import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthRemoteDataSource', () {
    test('register posts user data and returns the created profile', () async {
      final dataSource = AuthRemoteDataSource(
        backendBaseUrl: _backendBaseUrl,
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/usuarios/registro');
          expect(request.headers['Content-Type'], 'application/json');
          expect(jsonDecode(request.body), {
            'nombre': 'Ernesto',
            'apellido': 'Diaz',
            'email': 'ernesto@example.com',
            'cuit': '20-12345678-6',
            'password': 'Password1',
          });

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

      final userJson = await dataSource.register(
        firstName: 'Ernesto',
        lastName: 'Diaz',
        email: 'ernesto@example.com',
        cuit: '20-12345678-6',
        password: 'Password1',
      );

      expect(userJson, _userJson);
    });

    test('register exposes backend domain errors', () async {
      final dataSource = AuthRemoteDataSource(
        backendBaseUrl: _backendBaseUrl,
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'errors': [
                {
                  'code': 'email_ya_registrado',
                  'message': 'El email ya esta registrado',
                },
              ],
            }),
            409,
          );
        }),
      );

      expect(
        dataSource.register(
          firstName: 'Ernesto',
          lastName: 'Diaz',
          email: 'ernesto@example.com',
          cuit: '20-12345678-6',
          password: 'Password1',
        ),
        throwsA(
          isA<DomainException>().having(
            (error) => error.message,
            'message',
            'El email ya esta registrado',
          ),
        ),
      );
    });

    test('signIn parses the backend session contract', () async {
      final dataSource = AuthRemoteDataSource(
        backendBaseUrl: _backendBaseUrl,
        client: MockClient((request) async {
          expect(request.url.path, '/api/auth/login');
          expect(request.headers['Content-Type'], 'application/x-www-form-urlencoded');
          expect(request.bodyFields['username'], 'ernesto@example.com');

          return http.Response(
            jsonEncode({
              'success': true,
              'data': _sessionJson,
            }),
            200,
          );
        }),
      );

      final session = await dataSource.signIn(
        email: 'ernesto@example.com',
        password: 'Password1',
      );

      expect(session.accessToken, 'access-token');
      expect(session.refreshToken, 'refresh-token');
      expect(session.expiresIn, 3600);
      expect(session.userJson['email'], 'ernesto@example.com');
    });

    test('refreshSession posts the refresh token as JSON', () async {
      final dataSource = AuthRemoteDataSource(
        backendBaseUrl: _backendBaseUrl,
        client: MockClient((request) async {
          expect(request.url.path, '/api/auth/refresh');
          expect(request.headers['Content-Type'], 'application/json');
          expect(jsonDecode(request.body), {'refresh_token': 'refresh-token'});

          return http.Response(
            jsonEncode({
              'success': true,
              'data': _sessionJson,
            }),
            200,
          );
        }),
      );

      final session = await dataSource.refreshSession(
        refreshToken: 'refresh-token',
      );

      expect(session.accessToken, 'access-token');
      expect(session.refreshToken, 'refresh-token');
    });

    test('throws DomainException when required session fields are missing', () async {
      final dataSource = AuthRemoteDataSource(
        backendBaseUrl: _backendBaseUrl,
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'access_token': 'access-token',
                'usuario': _userJson,
              },
            }),
            200,
          );
        }),
      );

      expect(
        dataSource.signIn(
          email: 'ernesto@example.com',
          password: 'Password1',
        ),
        throwsA(isA<DomainException>()),
      );
    });
  });
}

const _backendBaseUrl = 'http://localhost:8000';

const _userJson = <String, Object?>{
  'id': '55c15f56-9f1c-4efd-8808-d2a31a5ddbb4',
  'nombre': 'Ernesto',
  'apellido': 'Diaz',
  'email': 'ernesto@example.com',
  'cuit': '20123456786',
};

const _sessionJson = <String, Object?>{
  'access_token': 'access-token',
  'refresh_token': 'refresh-token',
  'expires_in': 3600,
  'token_type': 'bearer',
  'usuario': _userJson,
};
