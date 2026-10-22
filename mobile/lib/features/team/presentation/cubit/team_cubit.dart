import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/team_permissions.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';

part 'team_cubit.freezed.dart';

/// Confirmación de una acción sobre el equipo.
enum TeamNotice {
  /// Se reenvió el email.
  resent,

  /// El código cambió pero no salió el email.
  resentWithoutEmail,

  /// Se canceló la invitación.
  cancelled,

  /// Se quitó a la persona.
  removed,
}

/// Datos de una acción terminada, sin confundir confirmación con persistencia.
typedef TeamActionResult = ({TeamNotice? notice, CreatedInvitation? created, DomainException? persistenceError});

/// Contexto, lectura y acción son operaciones independientes.
@freezed
sealed class TeamState with _$TeamState {
  /// Estado inicial de la pantalla.
  const factory TeamState({
    @Default(ResultState<EstablishmentMembership?>.initial()) ResultState<EstablishmentMembership?> context,
    TeamSnapshot? snapshot,
    @Default(ResultState<TeamSnapshot>.initial()) ResultState<TeamSnapshot> refresh,
    @Default(ResultState<TeamActionResult>.initial()) ResultState<TeamActionResult> action,
    @Default('') String actionId,
  }) = _TeamState;
  const TeamState._();

  /// Membresía resuelta por dominio.
  EstablishmentMembership? get establishment => switch (context) {
    Data<EstablishmentMembership?>(:final data) => data,
    _ => null,
  };

  /// Catálogo resuelto sin encontrar la membresía.
  bool get establishmentMissing => context is Data<EstablishmentMembership?> && establishment == null;

  /// Hay una lectura en curso.
  bool get isLoading =>
      context is Initial<EstablishmentMembership?> ||
      context is Loading<EstablishmentMembership?> ||
      refresh is Loading<TeamSnapshot>;

  /// No hay conexión confirmada por el último refresco.
  bool get isOffline => switch (action) {
    ResultError<TeamActionResult>(:final error) when error.code == DomainErrorCode.offline => true,
    _ => switch (refresh) {
      ResultError<TeamSnapshot>(:final error) => error.code == DomainErrorCode.offline,
      _ => false,
    },
  };

  /// ID ocupado solo durante la operación.
  String? get busyId => action is Loading<TeamActionResult> ? actionId : null;

  /// Error que debe interpretar presentación.
  DomainException? get error => switch (action) {
    ResultError<TeamActionResult>(:final error) => error,
    _ => switch (context) {
      ResultError<EstablishmentMembership?>(:final error) => error,
      _ => switch (refresh) {
        ResultError<TeamSnapshot>(:final error) when !isOffline || snapshot == null => error,
        _ => null,
      },
    },
  };

  /// Aviso de la acción confirmada.
  TeamNotice? get notice => switch (action) {
    Data<TeamActionResult>(:final data) => data.notice,
    _ => null,
  };

  /// Código efímero para compartir.
  CreatedInvitation? get created => switch (action) {
    Data<TeamActionResult>(:final data) => data.created,
    _ => null,
  };

  /// El guardado falló aunque backend confirmó la operación.
  DomainException? get persistenceError => switch (action) {
    Data<TeamActionResult>(:final data) => data.persistenceError,
    _ => null,
  };

  /// Reglas de dominio adaptadas al estado visual.
  bool canRemove(TeamMember member) =>
      actionsEnabled && canRemoveTeamMember(establishment?.role ?? UserRole.unknown, member);

  /// Reglas de dominio adaptadas al estado visual.
  bool canManageInvitation(TeamInvitation invitation) =>
      actionsEnabled && canManageTeamInvitation(establishment?.role ?? UserRole.unknown, invitation);

  /// Permiso local; el servidor sigue siendo la autoridad.
  bool get canManage => establishment?.role.canManageTeam ?? false;

  /// No se gestionan permisos sin un refresco exitoso ni durante otro request.
  bool get actionsEnabled => canManage && !isOffline && refresh is Data<TeamSnapshot> && busyId == null;
}

/// Publica cache y resultados conocidos; deja terminar la persistencia al salir.
class TeamCubit extends Cubit<TeamState> {
  /// Crea el Cubit de un establecimiento explícito.
  TeamCubit({
    required this.establishmentId,
    required GetTeamMembershipUseCase getMembership,
    required ReadCachedTeamUseCase readCached,
    required RefreshTeamUseCase refreshTeam,
    required ManageTeamUseCase manageTeam,
    bool Function()? isSessionCurrent,
  }) : _getMembership = getMembership,
       _readCached = readCached,
       _refreshTeam = refreshTeam,
       _manageTeam = manageTeam,
       _isSessionCurrent = isSessionCurrent ?? (() => true),
       super(const TeamState());

  final bool Function() _isSessionCurrent;
  bool get _canPresent => !isClosed && _isSessionCurrent();

  /// Establecimiento del equipo.
  final String establishmentId;
  final GetTeamMembershipUseCase _getMembership;
  final ReadCachedTeamUseCase _readCached;
  final RefreshTeamUseCase _refreshTeam;
  final ManageTeamUseCase _manageTeam;
  int _revision = 0;

  /// Inicialización propiedad del Cubit, nunca de una factory asíncrona.
  Future<void> load() async {
    if (!_canPresent || state.isLoading && state.context is! Initial<EstablishmentMembership?>) return;
    final revision = ++_revision;
    emit(state.copyWith(context: const ResultState.loading()));
    final membership = await _getMembership(establishmentId);
    if (!_canPresent || revision != _revision) return;
    switch (membership) {
      case Failure<EstablishmentMembership?>(:final error):
        emit(state.copyWith(context: ResultState.error(error)));
        return;
      case Success<EstablishmentMembership?>(:final data):
        emit(state.copyWith(context: ResultState.data(data)));
        if (data == null) return;
    }
    final cached = await _readCached(establishmentId);
    if (!_canPresent || revision != _revision) return;
    if (cached case Success<TeamSnapshot?>(:final data)) emit(state.copyWith(snapshot: data));
    await refresh();
  }

  /// Una lectura tardía no reemplaza una mutación más reciente.
  Future<void> refresh() async {
    if (!_canPresent || state.busyId != null) return;
    if (state.establishment == null) {
      await load();
      return;
    }
    final revision = ++_revision;
    emit(
      state.copyWith(
        refresh: const ResultState.loading(),
        action: state.action is ResultError<TeamActionResult> ? const ResultState.initial() : state.action,
      ),
    );
    final result = await _refreshTeam(establishmentId);
    if (!_canPresent || revision != _revision) return;
    switch (result) {
      case Success<TeamSnapshot>(:final data):
        emit(state.copyWith(snapshot: data, refresh: ResultState.data(data)));
      case Failure<TeamSnapshot>(:final error):
        emit(state.copyWith(refresh: ResultState.error(error)));
    }
  }

  /// Reconcilia inmediatamente una invitación creada desde otra ruta.
  void invitationCreated(TeamMutation<CreatedInvitation> mutation) {
    if (!_canPresent) return;
    ++_revision;
    emit(
      state.copyWith(
        snapshot: mutation.reconcile(state.snapshot),
        action: ResultState.data((
          notice: null,
          created: null,
          persistenceError: mutation.persistenceError,
        )),
      ),
    );
  }

  /// Aplica la confirmación recibida desde la ruta de compartir.
  void reconcileMutation(TeamMutation<void> mutation) {
    if (!_canPresent) return;
    ++_revision;
    emit(
      state.copyWith(
        snapshot: mutation.reconcile(state.snapshot),
        action: ResultState.data((
          notice: TeamNotice.cancelled,
          created: null,
          persistenceError: mutation.persistenceError,
        )),
      ),
    );
  }

  /// Libera el código del estado una vez entregado a la ruta de compartir.
  void consumeCreated() {
    if (!_canPresent) return;
    if (state.action case Data<TeamActionResult>(:final data)) {
      emit(
        state.copyWith(
          action: ResultState.data((notice: null, created: null, persistenceError: data.persistenceError)),
        ),
      );
    }
  }

  /// Reenvía y publica el nuevo código solo en memoria.
  Future<void> resend(TeamInvitation invitation) => _run(
    invitation.id,
    () => _manageTeam.resend(establishmentId, invitation),
    (created) =>
        (notice: created.invitation.emailSent ? TeamNotice.resent : TeamNotice.resentWithoutEmail, created: created),
  );

  /// Cancela una invitación conocida.
  Future<void> cancel(TeamInvitation invitation) => _run<void>(
    invitation.id,
    () => _manageTeam.cancel(establishmentId, invitation),
    (_) => (notice: TeamNotice.cancelled, created: null),
  );

  /// Quita un miembro conocido.
  Future<void> remove(TeamMember member) => _run<void>(
    member.userId,
    () => _manageTeam.remove(establishmentId, member),
    (_) => (notice: TeamNotice.removed, created: null),
  );

  Future<void> _run<T>(
    String id,
    Future<Result<TeamMutation<T>>> Function() operation,
    ({TeamNotice notice, CreatedInvitation? created}) Function(T) feedback,
  ) async {
    if (!_canPresent || !state.actionsEnabled) return;
    ++_revision;
    emit(state.copyWith(actionId: id, action: const ResultState.loading()));
    final result = await operation();
    if (!_canPresent) return;
    switch (result) {
      case Success<TeamMutation<T>>(:final data):
        final message = feedback(data.value);
        emit(
          state.copyWith(
            snapshot: data.reconcile(state.snapshot),
            action: ResultState.data((
              notice: message.notice,
              created: message.created,
              persistenceError: data.persistenceError,
            )),
          ),
        );
        await refresh();
      case Failure<TeamMutation<T>>(:final error):
        emit(state.copyWith(action: ResultState.error(error)));
    }
  }
}
