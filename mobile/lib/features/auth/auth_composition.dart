import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/bloc/login_cubit.dart';
import 'package:http/http.dart' as http;

/// Composition root de la feature de autenticacion.
LoginCubit createLoginCubit() {
  final client = http.Client();
  final repository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(
      backendBaseUrl: AppConfig.current.backendBaseUrl,
      client: client,
    ),
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  );

  return LoginCubit(
    signInUseCase: SignInUseCase(repository),
    onClose: client.close,
  );
}

/// Verifica la sesion actual contra `/api/auth/me`.
Future<Result<String>> verifyAuthenticatedUser() async {
  final client = http.Client();
  final repository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(
      backendBaseUrl: AppConfig.current.backendBaseUrl,
      client: client,
    ),
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  );

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

/// Cierra la sesion actual en memoria.
Future<void> signOutAuthenticatedUser() async {
  final client = http.Client();
  final repository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(
      backendBaseUrl: AppConfig.current.backendBaseUrl,
      client: client,
    ),
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  );

  try {
    await SignOutUseCase(repository)();
  } finally {
    client.close();
  }
}
