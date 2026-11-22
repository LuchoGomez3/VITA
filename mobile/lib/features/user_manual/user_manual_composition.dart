import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/user_manual/data/repositories/user_manual_repository_impl.dart';
import 'package:frontend_mayoral/features/user_manual/domain/use_cases/get_user_manual_use_case.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/cubit/user_manual_cubit.dart';

const _catalog = EstablishmentCatalog(secureStorage: FlutterSecureStorageService());

/// Construye el Cubit del manual: lee los assets y filtra con los roles del
/// catálogo offline de establecimientos.
UserManualCubit createUserManualCubit() => UserManualCubit(
  GetUserManualUseCase(
    repository: UserManualRepositoryImpl(),
    readMemberships: _catalog.getMemberships,
  ),
);
