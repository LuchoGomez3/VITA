import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/profile/data/datasources/profile_appearance_local_data_source.dart';
import 'package:frontend_mayoral/features/profile/data/datasources/profile_appearance_remote_data_source.dart';
import 'package:frontend_mayoral/features/profile/data/repositories/profile_appearance_repository_impl.dart';
import 'package:frontend_mayoral/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:frontend_mayoral/features/profile/domain/use_cases/get_profile_establishments_use_case.dart';
import 'package:frontend_mayoral/features/profile/domain/use_cases/profile_appearance_use_cases.dart';
import 'package:frontend_mayoral/features/profile/presentation/cubit/profile_appearance_cubit.dart';
import 'package:frontend_mayoral/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:frontend_mayoral/features/profile/presentation/pages/profile_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Construye el Cubit de Perfil con sus dependencias.
ProfileCubit createProfileCubit() {
  const repository = ProfileRepositoryImpl(
    secureStorage: FlutterSecureStorageService(),
  );
  return ProfileCubit(const GetProfileEstablishmentsUseCase(repository));
}

/// Lee la versión de la app instalada (la del `pubspec.yaml` al compilar).
Future<AppVersion> readInstalledAppVersion() async {
  final info = await PackageInfo.fromPlatform();
  return (version: info.version, buildNumber: info.buildNumber);
}

/// Construye el Cubit de la apariencia de Perfil (color y foto) de [userId].
ProfileAppearanceCubit createProfileAppearanceCubit(String userId) {
  final repository = ProfileAppearanceRepositoryImpl(
    local: const ProfileAppearanceLocalDataSource(
      secureStorage: FlutterSecureStorageService(),
      files: DocumentsAvatarFileStore(),
    ),
    remote: ProfileAppearanceRemoteDataSource(
      baseUrl: AppConfig.current.backendBaseUrl,
      tokenProvider: SessionBackendAccessTokenProvider.instance,
    ),
  );
  return ProfileAppearanceCubit(
    userId: userId,
    load: LoadProfileAppearanceUseCase(repository),
    sync: SyncProfileAppearanceUseCase(repository),
    changeHeaderColor: ChangeHeaderColorUseCase(repository),
    changeAvatar: ChangeAvatarUseCase(repository),
    removeAvatar: RemoveAvatarUseCase(repository),
  );
}
