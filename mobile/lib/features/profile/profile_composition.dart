import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:frontend_mayoral/features/profile/domain/use_cases/get_profile_establishments_use_case.dart';
import 'package:frontend_mayoral/features/profile/presentation/cubit/profile_cubit.dart';

/// Construye el Cubit de Perfil con sus dependencias.
ProfileCubit createProfileCubit() {
  const repository = ProfileRepositoryImpl(
    secureStorage: FlutterSecureStorageService(),
  );
  return ProfileCubit(const GetProfileEstablishmentsUseCase(repository));
}
