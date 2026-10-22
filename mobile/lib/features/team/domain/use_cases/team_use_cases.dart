import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:frontend_mayoral/features/team/domain/repositories/team_repository.dart';
import 'package:frontend_mayoral/features/team/domain/team_permissions.dart';

/// Resuelve el contexto local de un establecimiento explícito.
class GetTeamMembershipUseCase {
  /// Crea el caso de uso.
  const GetTeamMembershipUseCase(this._repository);
  final TeamRepository _repository;

  /// Falla sin conceder permisos si no se puede leer el catálogo.
  Future<Result<EstablishmentMembership?>> call(String id) => _repository.findEstablishment(id);
}

/// Lee el equipo guardado para un establecimiento explícito.
class ReadCachedTeamUseCase {
  /// Crea el caso de uso.
  const ReadCachedTeamUseCase(this._repository);
  final TeamRepository _repository;

  /// Conserva fallas esperables dentro del contrato Result.
  Future<Result<TeamSnapshot?>> call(String id) => _repository.readCached(id);
}

/// Reconcilia el equipo con el servidor.
class RefreshTeamUseCase {
  /// Crea el caso de uso.
  const RefreshTeamUseCase(this._repository);
  final TeamRepository _repository;

  /// Refresca únicamente el establecimiento solicitado.
  Future<Result<TeamSnapshot>> call(String id) => _repository.refresh(id);
}

/// Valida email y permisos antes de invitar; el backend vuelve a autorizar.
class InviteTeamMemberUseCase {
  /// Crea el caso de uso.
  const InviteTeamMemberUseCase(this._repository);
  final TeamRepository _repository;
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Invita con un email normalizado y un rol permitido en este campo.
  Future<Result<TeamMutation<CreatedInvitation>>> call(
    String id, {
    required String email,
    required UserRole role,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return Result.failure(teamError(TeamErrorReason.emailRequired));
    if (!_emailPattern.hasMatch(normalized)) return Result.failure(teamError(TeamErrorReason.emailInvalid));
    final permission = await _canAssign(_repository, id, role);
    if (permission case Failure<void>(:final error)) return Result.failure(error);
    return _repository.invite(id, email: normalized, role: role);
  }
}

Future<Result<void>> _canAssign(TeamRepository repository, String id, UserRole role) async {
  final membership = await repository.findEstablishment(id);
  return membership.when(
    success: (data) => (data?.role.assignableRoles.contains(role) ?? false)
        ? const Result.success(null)
        : Result.failure(teamError(TeamErrorReason.roleNotAssignable)),
    failure: Result.failure,
  );
}

/// Gestión sobre datos conocidos; los permisos tienen dueño en dominio.
class ManageTeamUseCase {
  /// Crea el caso de uso.
  const ManageTeamUseCase(this._repository);
  final TeamRepository _repository;

  /// Reenvía únicamente invitaciones con un rol asignable.
  Future<Result<TeamMutation<CreatedInvitation>>> resend(String id, TeamInvitation invitation) async {
    final permission = await _canAssign(_repository, id, invitation.role);
    if (permission case Failure<void>(:final error)) return Result.failure(error);
    return _repository.resend(id, invitation.id);
  }

  /// Cancela únicamente invitaciones con un rol asignable.
  Future<Result<TeamMutation<void>>> cancel(String id, TeamInvitation invitation) async {
    final permission = await _canAssign(_repository, id, invitation.role);
    if (permission case Failure<void>(:final error)) return Result.failure(error);
    return _repository.cancel(id, invitation.id);
  }

  /// Protege al titular y restringe los roles que puede quitar un admin.
  Future<Result<TeamMutation<void>>> remove(String id, TeamMember member) async {
    if (member.isHolder) return Result.failure(teamError(TeamErrorReason.holderNotRemovable));
    final membership = await _repository.findEstablishment(id);
    if (membership case Failure<EstablishmentMembership?>(:final error)) return Result.failure(error);
    if (membership case Success<EstablishmentMembership?>(
      :final data,
    ) when canRemoveTeamMember(data?.role ?? UserRole.unknown, member)) {
      return _repository.removeMember(id, member.userId);
    }
    return Result.failure(teamError(TeamErrorReason.notAllowed));
  }
}

/// Previsualiza y canjea; el servidor reconoce reintentos del mismo aceptante.
class JoinEstablishmentUseCase {
  /// La preparación usa el contrato público de bootstrap de la sesión.
  const JoinEstablishmentUseCase(this._repository, {required PreparePostAuthentication prepareData})
    : _prepareData = prepareData;
  final TeamRepository _repository;
  final PreparePostAuthentication _prepareData;

  /// Muestra el alcance del código sin consumirlo.
  Future<Result<InvitationPreview>> preview(String code) => _repository.preview(code);

  /// Confirma en backend y conserva por separado el resultado del storage.
  Future<Result<TeamAcceptance>> accept(String code) => _repository.accept(code);

  /// Comprueba la membresía recuperada por la sincronización de sesión.
  Future<Result<EstablishmentMembership?>> findMembership(String id) => _repository.findEstablishment(id);

  /// Recupera membresías desde backend y descarga datos sin volver a canjear.
  Future<Result<PostAuthenticationSummary>> synchronize() => _prepareData();
}
