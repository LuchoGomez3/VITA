import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/repositories/team_repository.dart';

/// Lee el equipo guardado en el celular.
class ReadCachedTeamUseCase {
  /// Crea el caso de uso.
  const ReadCachedTeamUseCase(this._repository);

  final TeamRepository _repository;

  /// Ejecuta la lectura para [establishmentId].
  Future<TeamSnapshot?> call(String establishmentId) => _repository.readCached(establishmentId);
}

/// Trae el equipo del servidor.
class RefreshTeamUseCase {
  /// Crea el caso de uso.
  const RefreshTeamUseCase(this._repository);

  final TeamRepository _repository;

  /// Ejecuta el refresco para [establishmentId].
  Future<Result<TeamSnapshot>> call(String establishmentId) => _repository.refresh(establishmentId);
}

/// Invita a una persona por email.
class InviteTeamMemberUseCase {
  /// Crea el caso de uso.
  const InviteTeamMemberUseCase(this._repository);

  final TeamRepository _repository;

  /// Invita a [email] con [role] en [establishmentId].
  Future<Result<TeamInvitation>> call(String establishmentId, {required String email, required UserRole role}) =>
      _repository.invite(establishmentId, email: email, role: role);
}

/// Reenvía, cancela y quita: las acciones sobre el equipo ya cargado.
class ManageTeamUseCase {
  /// Crea el caso de uso.
  const ManageTeamUseCase(this._repository);

  final TeamRepository _repository;

  /// Genera un código nuevo y reenvía el email.
  Future<Result<TeamInvitation>> resend(String establishmentId, String invitationId) =>
      _repository.resend(establishmentId, invitationId);

  /// Cancela la invitación.
  Future<Result<void>> cancel(String establishmentId, String invitationId) =>
      _repository.cancel(establishmentId, invitationId);

  /// Quita a la persona del equipo.
  Future<Result<void>> remove(String establishmentId, String userId) =>
      _repository.removeMember(establishmentId, userId);
}

/// Previsualiza y canjea un código de invitación.
class JoinEstablishmentUseCase {
  /// Crea el caso de uso.
  const JoinEstablishmentUseCase(this._repository);

  final TeamRepository _repository;

  /// Muestra a qué campo y con qué rol se suma [code].
  Future<Result<InvitationPreview>> preview(String code) => _repository.preview(code);

  /// Canjea [code].
  Future<Result<EstablishmentMembership>> accept(String code) => _repository.accept(code);
}
