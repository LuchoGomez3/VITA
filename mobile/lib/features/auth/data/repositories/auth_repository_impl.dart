import 'dart:async';
import 'dart:io';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/mappers/app_user_mapper.dart';
import 'package:frontend_mayoral/features/auth/data/models/auth_remote_session.dart';
import 'package:frontend_mayoral/features/auth/data/models/stored_auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Implementacion de autenticacion que combina backend, secure storage y Brick.
///
/// Responsabilidades:
/// - Login requiere red y obtiene la sesion desde el backend.
/// - Restore es local/offline y reconstruye la sesion desde secure storage.
/// - El token provider queda hidratado para que Brick pueda sincronizar sin
///   conocer la feature auth ni leer storage por su cuenta.
class AuthRepositoryImpl implements AuthRepository {
  /// Crea el repositorio con fuentes remota/local y provider compartido.
  const AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required SessionBackendAccessTokenProvider tokenProvider,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _tokenProvider = tokenProvider;

  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final SessionBackendAccessTokenProvider _tokenProvider;

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final remoteSession = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      final session = _sessionFromRemote(remoteSession);

      await _persistAndHydrate(session);
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
          message: 'El backend tardo demasiado en responder.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }

  @override
  Future<Result<AuthSession>> restoreSession() async {
    try {
      final storedSession = await _localDataSource.readSession();
      if (storedSession == null) {
        _tokenProvider.clearAccessToken();
        return const Result.failure(
          DomainException(
            message: 'No hay una sesion guardada en este dispositivo.',
            code: DomainErrorCode.unauthorized,
          ),
        );
      }

      final session = storedSession.toDomain();
      _hydrateTokenProvider(session);
      return Result.success(session);
    } on FormatException {
      await _localDataSource.clearSession();
      _tokenProvider.clearAccessToken();
      return const Result.failure(
        DomainException(
          message: 'La sesion local no se pudo restaurar.',
          code: DomainErrorCode.unauthorized,
        ),
      );
    }
  }

  @override
  Future<Result<AuthSession>> refreshSession({
    String? refreshTokenOverride,
  }) async {
    try {
      final storedSession = await _localDataSource.readSession();
      if (storedSession == null) {
        _tokenProvider.clearAccessToken();
        return const Result.failure(
          DomainException(
            message: 'No hay una sesion guardada en este dispositivo.',
            code: DomainErrorCode.unauthorized,
          ),
        );
      }

      final refreshToken = refreshTokenOverride ?? storedSession.refreshToken;
      final remoteSession = await _remoteDataSource.refreshSession(
        refreshToken: refreshToken,
      );
      final session = _sessionFromRemote(remoteSession);

      await _persistAndHydrate(session);
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
          message: 'El backend tardo demasiado en responder.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }

  @override
  Future<Result<AuthSession>> getCurrentSession() {
    return restoreSession();
  }

  @override
  Future<Result<AppUser>> getCurrentUser() async {
    final sessionResult = await getCurrentSession();
    return switch (sessionResult) {
      Success<AuthSession>(:final data) => Result.success(data.user),
      Failure<AuthSession>(:final error) => Result.failure(error),
      _ => const Result.failure(
        DomainException(
          message: 'No hay una sesion iniciada.',
          code: DomainErrorCode.unauthorized,
        ),
      ),
    };
  }

  @override
  Future<void> signOut() async {
    await _localDataSource.clearSession();
    _tokenProvider.clearAccessToken();
  }

  Future<void> _persistAndHydrate(AuthSession session) async {
    await _localDataSource.saveSession(
      StoredAuthSession.fromDomain(session),
    );
    _hydrateTokenProvider(session);
  }

  AuthSession _sessionFromRemote(AuthRemoteSession remoteSession) {
    return AuthSession(
      user: AppUserMapper.fromJson(remoteSession.userJson),
      accessToken: remoteSession.accessToken,
      refreshToken: remoteSession.refreshToken,
      accessTokenExpiresAt: DateTime.now().toUtc().add(
        Duration(seconds: remoteSession.expiresIn),
      ),
    );
  }

  void _hydrateTokenProvider(AuthSession session) {
    _tokenProvider.session = BackendTokenSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      accessTokenExpiresAt: session.accessTokenExpiresAt,
    );
  }
}
