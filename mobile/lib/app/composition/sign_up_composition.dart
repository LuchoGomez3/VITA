import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/bloc/sign_up_cubit.dart';
import 'package:http/http.dart' as http;

/// Construye el Cubit del registro con todas sus dependencias.
SignUpCubit createSignUpCubit() {
  final client = http.Client();
  final repository = AuthRepositoryImpl(
    localDataSource: const AuthLocalDataSource(
      secureStorage: FlutterSecureStorageService(),
    ),
    remoteDataSource: AuthRemoteDataSource(
      backendBaseUrl: AppConfig.current.backendBaseUrl,
      client: client,
    ),
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  );

  return SignUpCubit(
    registerUserUseCase: RegisterUserUseCase(repository),
    onClose: client.close,
  );
}
