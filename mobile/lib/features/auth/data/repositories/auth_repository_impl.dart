import 'dart:async';
import 'dart:io';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/mappers/app_user_mapper.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Implementacion HTTP de autenticacion contra el backend.
class AuthRepositoryImpl implements AuthRepository {
  /// Crea el repositorio con data source remoto y provider compartido de token.
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SessionBackendAccessTokenProvider tokenProvider,
  }) : _remoteDataSource = remoteDataSource,
       _tokenProvider = tokenProvider;

  final AuthRemoteDataSource _remoteDataSource;
  final SessionBackendAccessTokenProvider _tokenProvider;

  @override
  Future<Result<AuthSession>> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final accessToken = await _remoteDataSource.signIn(
        username: username,
        password: password,
      );
      _tokenProvider.accessToken = accessToken;

      final userJson = await _remoteDataSource.getCurrentUser(accessToken);
      final session = AuthSession(
        user: AppUserMapper.fromJson(userJson),
        accessToken: accessToken,
      );

      return Result.success(session);
    } on DomainException catch (error) {
      return Result.failure(error);
    } on SocketException {
      return const Result.failure(
        DomainException(
          message: 'No se pudo conectar con el backend.',
          code: DomainErrorCode.offline,
        ),
      );
    } on TimeoutException {
      return const Result.failure(
        DomainException(
          message: 'El backend tardó demasiado en responder.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }

  @override
  Future<Result<AppUser>> getCurrentUser() async {
    final accessToken = await _tokenProvider.getAccessToken();
    if (accessToken == null) {
      return const Result.failure(
        DomainException(
          message: 'No hay una sesión iniciada.',
          code: DomainErrorCode.unauthorized,
        ),
      );
    }

    try {
      final userJson = await _remoteDataSource.getCurrentUser(accessToken);
      return Result.success(AppUserMapper.fromJson(userJson));
    } on DomainException catch (error) {
      return Result.failure(error);
    } on SocketException {
      return const Result.failure(
        DomainException(
          message: 'No se pudo conectar con el backend.',
          code: DomainErrorCode.offline,
        ),
      );
    } on TimeoutException {
      return const Result.failure(
        DomainException(
          message: 'El backend tardó demasiado en responder.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }

  @override
  Future<void> signOut() async {
    _tokenProvider.clearAccessToken();
  }
}
