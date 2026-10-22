import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/team/data/datasources/team_remote_data_source.dart';
import 'package:frontend_mayoral/features/team/data/repositories/team_repository_impl.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/repositories/team_repository.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/invitation_created_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/invite_team_member_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/team_cubit.dart';

const _storage = FlutterSecureStorageService();
const _catalog = EstablishmentCatalog(secureStorage: _storage);

/// Crea el repositorio compartido por las rutas de una sesión.
TeamRepository createTeamRepository({Future<void> Function(Future<void> Function())? updateCatalog}) {
  final provider = SessionBackendAccessTokenProvider.instance;
  final generation = provider.sessionGeneration;
  bool isCurrent() => generation == provider.sessionGeneration;
  return TeamRepositoryImpl(
    remote: TeamRemoteDataSource(
      baseUrl: AppConfig.current.backendBaseUrl,
      tokenProvider: provider,
      isSessionCurrent: isCurrent,
    ),
    secureStorage: _storage,
    establishmentCatalog: _catalog,
    updateCatalog: updateCatalog,
    isSessionCurrent: isCurrent,
    persistSessionData: provider.persistSessionData,
  );
}

/// Conecta dependencias de Equipo; no consulta el catálogo.
TeamCubit createTeamCubit(String establishmentId, {required TeamRepository repository}) {
  return TeamCubit(
    establishmentId: establishmentId,
    isSessionCurrent: _sessionGuard(),
    getMembership: GetTeamMembershipUseCase(repository),
    readCached: ReadCachedTeamUseCase(repository),
    refreshTeam: RefreshTeamUseCase(repository),
    manageTeam: ManageTeamUseCase(repository),
  );
}

/// Construye sincrónicamente; BlocProvider posee la instancia desde el inicio.
InviteTeamMemberCubit createInviteTeamMemberCubit(String establishmentId, {required TeamRepository repository}) {
  return InviteTeamMemberCubit(
    establishmentId: establishmentId,
    isSessionCurrent: _sessionGuard(),
    getMembership: GetTeamMembershipUseCase(repository),
    invite: InviteTeamMemberUseCase(repository),
  );
}

/// Conecta la cancelación a su Cubit de ruta.
InvitationCreatedCubit createInvitationCreatedCubit(
  String establishmentId,
  TeamInvitation invitation, {
  required TeamRepository repository,
}) => InvitationCreatedCubit(
  establishmentId: establishmentId,
  isSessionCurrent: _sessionGuard(),
  invitation: invitation,
  manageTeam: ManageTeamUseCase(repository),
);

/// La sincronización pertenece a la sesión, que también cierra su cliente HTTP.
JoinEstablishmentCubit createJoinEstablishmentCubit({
  required PreparePostAuthentication prepareData,
  required TeamRepository repository,
}) => JoinEstablishmentCubit(
  JoinEstablishmentUseCase(repository, prepareData: prepareData),
  isSessionCurrent: _sessionGuard(),
);

bool Function() _sessionGuard() {
  final provider = SessionBackendAccessTokenProvider.instance;
  final generation = provider.sessionGeneration;
  return () => generation == provider.sessionGeneration;
}
