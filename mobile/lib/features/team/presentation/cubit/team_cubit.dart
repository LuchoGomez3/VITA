import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:meta/meta.dart';

/// Qué avisarle al usuario después de una acción sobre el equipo.
enum TeamNotice {
  /// Se reenvió el email con un código nuevo.
  resent,

  /// Se generó un código nuevo pero el email no salió.
  resentWithoutEmail,

  /// Se canceló la invitación.
  cancelled,

  /// Se quitó a la persona del equipo.
  removed,
}

/// Estado de la pantalla Equipo.
@immutable
class TeamState {
  /// Crea el estado.
  const TeamState({
    this.establishment,
    this.snapshot,
    this.isLoading = false,
    this.isOffline = false,
    this.establishmentMissing = false,
    this.busyId,
    this.notice,
    this.error,
    this.created,
  });

  /// Establecimiento y rol propio, del catálogo del celular.
  final EstablishmentMembership? establishment;

  /// Equipo a mostrar: el del servidor o el último guardado.
  final TeamSnapshot? snapshot;

  /// Si se está trayendo el equipo del servidor.
  final bool isLoading;

  /// El último intento de traer el equipo fue sin conexión: se muestra lo
  /// guardado y las acciones quedan deshabilitadas.
  final bool isOffline;

  /// El establecimiento no está en el catálogo (p. ej. sesión de otra persona).
  final bool establishmentMissing;

  /// Invitación o miembro con una acción en curso.
  final String? busyId;

  /// Aviso de la última acción, para mostrarlo una vez.
  final TeamNotice? notice;

  /// Error de la última acción, para mostrarlo una vez.
  final DomainException? error;

  /// Invitación reenviada con su código nuevo, para abrir la pantalla de
  /// compartir una vez.
  final CreatedInvitation? created;

  /// Si la persona puede invitar, reenviar, cancelar y quitar.
  bool get canManage => establishment?.role.canManageTeam ?? false;

  /// Si las acciones están disponibles ahora (hay señal y nada en curso).
  bool get actionsEnabled => canManage && !isOffline && busyId == null;

  TeamState _copyWith({
    EstablishmentMembership? establishment,
    TeamSnapshot? snapshot,
    bool? isLoading,
    bool? isOffline,
    bool? establishmentMissing,
    String? busyId,
    bool clearBusy = false,
    TeamNotice? notice,
    DomainException? error,
    CreatedInvitation? created,
  }) => TeamState(
    establishment: establishment ?? this.establishment,
    snapshot: snapshot ?? this.snapshot,
    isLoading: isLoading ?? this.isLoading,
    isOffline: isOffline ?? this.isOffline,
    establishmentMissing: establishmentMissing ?? this.establishmentMissing,
    busyId: clearBusy ? null : (busyId ?? this.busyId),
    notice: notice,
    error: error,
    created: created,
  );

  @override
  bool operator ==(Object other) =>
      other is TeamState &&
      other.establishment == establishment &&
      other.snapshot == snapshot &&
      other.isLoading == isLoading &&
      other.isOffline == isOffline &&
      other.establishmentMissing == establishmentMissing &&
      other.busyId == busyId &&
      other.notice == notice &&
      other.error == error &&
      other.created == created;

  @override
  int get hashCode =>
      Object.hash(establishment, snapshot, isLoading, isOffline, establishmentMissing, busyId, notice, error, created);
}

/// Muestra el equipo (primero lo guardado, después lo del servidor) y aplica
/// las acciones de gestión, que son online-only.
class TeamCubit extends Cubit<TeamState> {
  /// Crea el Cubit para [establishmentId].
  TeamCubit({
    required this.establishmentId,
    required Future<EstablishmentMembership?> Function(String establishmentId) findEstablishment,
    required ReadCachedTeamUseCase readCached,
    required RefreshTeamUseCase refreshTeam,
    required ManageTeamUseCase manageTeam,
  }) : _findEstablishment = findEstablishment,
       _readCached = readCached,
       _refreshTeam = refreshTeam,
       _manageTeam = manageTeam,
       super(const TeamState());

  /// Establecimiento cuyo equipo se muestra.
  final String establishmentId;

  final Future<EstablishmentMembership?> Function(String establishmentId) _findEstablishment;
  final ReadCachedTeamUseCase _readCached;
  final RefreshTeamUseCase _refreshTeam;
  final ManageTeamUseCase _manageTeam;

  /// Resuelve el establecimiento, muestra lo guardado y refresca.
  Future<void> load() async {
    final establishment = await _findEstablishment(establishmentId);
    if (establishment == null) {
      emit(state._copyWith(establishmentMissing: true));
      return;
    }
    final cached = await _readCached(establishmentId);
    emit(state._copyWith(establishment: establishment, snapshot: cached, isLoading: true));
    await refresh();
  }

  /// Trae el equipo del servidor. Sin señal conserva lo guardado.
  Future<void> refresh() async {
    emit(state._copyWith(isLoading: true));
    final result = await _refreshTeam(establishmentId);
    switch (result) {
      case Success<TeamSnapshot>(:final data):
        emit(state._copyWith(snapshot: data, isLoading: false, isOffline: false));
      case Failure<TeamSnapshot>(:final error):
        final offline = error.code == DomainErrorCode.offline;
        // Sin conexión no es un error si hay algo guardado para mostrar.
        emit(
          state._copyWith(
            isLoading: false,
            isOffline: offline,
            error: offline && state.snapshot != null ? null : error,
          ),
        );
    }
  }

  /// Genera un código nuevo para [invitation], reenvía el email y expone el
  /// código en [TeamState.created] para compartirlo.
  Future<void> resend(TeamInvitation invitation) async {
    if (!state.actionsEnabled) {
      return;
    }
    emit(state._copyWith(busyId: invitation.id));
    final result = await _manageTeam.resend(establishmentId, invitation.id);
    switch (result) {
      case Success<CreatedInvitation>(:final data):
        emit(
          state._copyWith(
            clearBusy: true,
            created: data,
            notice: data.invitation.emailSent ? TeamNotice.resent : TeamNotice.resentWithoutEmail,
          ),
        );
        await refresh();
      case Failure<CreatedInvitation>(:final error):
        emit(state._copyWith(clearBusy: true, error: error, isOffline: error.code == DomainErrorCode.offline));
    }
  }

  /// Cancela [invitation].
  Future<void> cancel(TeamInvitation invitation) => _run(invitation.id, () async {
    final result = await _manageTeam.cancel(establishmentId, invitation.id);
    return result is Success ? (TeamNotice.cancelled, null) : (null, _errorOf(result));
  });

  /// Quita a [member] del equipo.
  Future<void> remove(TeamMember member) => _run(member.userId, () async {
    final result = await _manageTeam.remove(establishmentId, member.userId);
    return result is Success ? (TeamNotice.removed, null) : (null, _errorOf(result));
  });

  static DomainException _errorOf(Result<Object?> result) =>
      result is Failure<Object?> ? result.error : const DomainException(message: 'Error inesperado.');

  Future<void> _run(String id, Future<(TeamNotice?, DomainException?)> Function() action) async {
    if (!state.actionsEnabled) {
      return;
    }
    emit(state._copyWith(busyId: id));
    final (notice, error) = await action();
    if (error != null) {
      emit(state._copyWith(clearBusy: true, error: error, isOffline: error.code == DomainErrorCode.offline));
      return;
    }
    emit(state._copyWith(clearBusy: true, notice: notice));
    await refresh();
  }
}
