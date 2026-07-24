import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend_mayoral/features/auth/data/repositories/initial_data_sync_repository_impl.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/prepare_initial_data_sync_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/restore_session_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/auth/presentation/bloc/login_cubit.dart';
import 'package:http/http.dart' as http;

/// Composition root de la feature de autenticacion.
///
/// Todavia usamos wiring manual para no introducir un contenedor de DI. La
/// regla practica es que presentation recibe use cases/cubits ya armados, y
/// solo este archivo conoce data sources, storage seguro y cliente HTTP.

// TODO(agustin): Reemplazar este wiring manual cuando definamos la estrategia
// comun para crear BLoCs/repositories. Opciones probables: RepositoryProvider /
// MultiBlocProvider, providers a nivel router, o un container tipo get_it +
// injectable. En el flujo final, la page deberia conocer solo al BLoC.

bool _tokenRefreshConfigured = false;

/// Crea el cubit global que restaura y cierra sesiones.
AuthSessionCubit createAuthSessionCubit() {
  final client = http.Client();
  final repository = _createAuthRepository(client);

  return AuthSessionCubit(
    restoreSessionUseCase: RestoreSessionUseCase(repository),
    signOutUseCase: SignOutUseCase(repository),
    onClose: client.close,
  );
}

/// Crea el cubit local de la pantalla de login.
LoginCubit createLoginCubit() {
  final client = http.Client();
  final repository = _createAuthRepository(client);
  const secureStorage = FlutterSecureStorageService();

  return LoginCubit(
    signInUseCase: SignInUseCase(repository),
    prepareInitialDataSyncUseCase: PrepareInitialDataSyncUseCase(
      InitialDataSyncRepositoryImpl(
        secureStorage: secureStorage,
        establishmentRemoteDataSource: EstablishmentRemoteDataSource(
          backendBaseUrl: AppConfig.current.backendBaseUrl,
          tokenProvider: SessionBackendAccessTokenProvider.instance,
          client: client,
        ),
        animalStore: BrickAnimalStore.instance,
        categoryStore: BrickCategoriaStore.instance,
        weighingStore: BrickPesajeStore.instance,
      ),
    ),
    onClose: client.close,
  );
}

/// Lee el usuario autenticado desde la sesion local.
///
/// Este helper sigue existiendo para la Home mock. No llama al backend, por lo
/// que sirve para probar que la app puede abrir offline con sesion restaurada.
Future<Result<String>> verifyAuthenticatedUser() async {
  final client = http.Client();
  final repository = _createAuthRepository(client);

  try {
    final result = await GetCurrentUserUseCase(repository)();

    return switch (result) {
      Success<AppUser>(:final data) => Result.success(
        '${data.firstName} ${data.lastName} (${data.email})',
      ),
      Failure<AppUser>(:final error) => Result.failure(error),
      _ => const Result.failure(
        DomainException(message: 'No se pudo verificar la sesion.'),
      ),
    };
  } finally {
    client.close();
  }
}

/// Cierra la sesion actual en storage seguro y memoria.
Future<void> signOutAuthenticatedUser() async {
  final client = http.Client();
  final repository = _createAuthRepository(client);

  try {
    await SignOutUseCase(repository)();
  } finally {
    client.close();
  }
}

AuthRepositoryImpl _createAuthRepository(http.Client client) {
  _ensureTokenRefreshConfigured();
  return AuthRepositoryImpl(
    localDataSource: const AuthLocalDataSource(
      secureStorage: FlutterSecureStorageService(),
    ),
    remoteDataSource: AuthRemoteDataSource(
      backendBaseUrl: AppConfig.current.backendBaseUrl,
      client: client,
    ),
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  );
}

void _ensureTokenRefreshConfigured() {
  if (_tokenRefreshConfigured) {
    return;
  }

  _tokenRefreshConfigured = true;
  SessionBackendAccessTokenProvider.instance.refreshCallback = (refreshToken) async {
    final client = http.Client();
    final repository = _createAuthRepository(client);

    try {
      final result = await repository.refreshSession(
        refreshTokenOverride: refreshToken,
      );
      return switch (result) {
        Success<AuthSession>(:final data) => BackendTokenSession(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          accessTokenExpiresAt: data.accessTokenExpiresAt,
        ),
        Failure<AuthSession>(:final error) => switch (error.code) {
          DomainErrorCode.unauthorized => throw error,
          _ => null,
        },
        _ => null,
      };
    } finally {
      client.close();
    }
  };
}
