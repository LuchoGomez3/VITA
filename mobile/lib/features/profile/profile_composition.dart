import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:frontend_mayoral/features/profile/domain/use_cases/get_profile_establishments_use_case.dart';
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
