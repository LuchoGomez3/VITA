import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/sync/sync_composition.dart';
import 'package:frontend_mayoral/features/team/data/datasources/team_remote_data_source.dart';
import 'package:frontend_mayoral/features/team/data/repositories/team_repository_impl.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/invite_team_member_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/team_cubit.dart';
import 'package:http/http.dart' as http;

const _storage = FlutterSecureStorageService();
const _catalog = EstablishmentCatalog(secureStorage: _storage);

TeamRepositoryImpl _repository() => TeamRepositoryImpl(
  remote: TeamRemoteDataSource(
    baseUrl: AppConfig.current.backendBaseUrl,
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  ),
  secureStorage: _storage,
  establishmentCatalog: _catalog,
);

/// Construye el Cubit de la pantalla Equipo de [establishmentId].
TeamCubit createTeamCubit(String establishmentId) {
  final repository = _repository();
  return TeamCubit(
    establishmentId: establishmentId,
    findEstablishment: _catalog.getById,
    readCached: ReadCachedTeamUseCase(repository),
    refreshTeam: RefreshTeamUseCase(repository),
    manageTeam: ManageTeamUseCase(repository),
  );
}

/// Construye el Cubit de Invitar; `null` si la persona no puede invitar en
/// [establishmentId] según el catálogo del celular.
Future<InviteTeamMemberCubit?> createInviteTeamMemberCubit(String establishmentId) async {
  final membership = await _catalog.getById(establishmentId);
  final roles = membership?.role.assignableRoles ?? const <UserRole>[];
  if (roles.isEmpty) {
    return null;
  }
  return InviteTeamMemberCubit(
    establishmentId: establishmentId,
    assignableRoles: roles,
    invite: InviteTeamMemberUseCase(_repository()),
  );
}

/// Cancela una invitación (desde "Invitación creada").
Future<Result<void>> cancelTeamInvitation(String establishmentId, String invitationId) =>
    ManageTeamUseCase(_repository()).cancel(establishmentId, invitationId);

/// Construye el Cubit de "Sumarme a otro establecimiento". Después de sumarse
/// corre la misma sincronización inicial que el login, para bajar los datos del
/// campo nuevo.
JoinEstablishmentCubit createJoinEstablishmentCubit() => JoinEstablishmentCubit(
  JoinEstablishmentUseCase(_repository()),
  syncData: createPrepareInitialDataSyncUseCase(client: http.Client()).call,
);
