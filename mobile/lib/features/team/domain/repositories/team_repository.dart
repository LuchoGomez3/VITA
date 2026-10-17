import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';

/// Equipo de un establecimiento e invitaciones por código (adr-0012).
///
/// Las acciones que cambian el equipo son online-only: invitar manda un email y
/// canjear necesita que el servidor valide el código. La lista se cachea para
/// verla sin conexión.
abstract interface class TeamRepository {
  /// Último equipo guardado en el celular para [establishmentId], si hay.
  Future<TeamSnapshot?> readCached(String establishmentId);

  /// Trae el equipo del servidor y lo guarda en el celular.
  Future<Result<TeamSnapshot>> refresh(String establishmentId);

  /// Invita a [email] con [role]; el código viaja solo en el email.
  Future<Result<TeamInvitation>> invite(String establishmentId, {required String email, required UserRole role});

  /// Genera un código nuevo y reenvía el email.
  Future<Result<TeamInvitation>> resend(String establishmentId, String invitationId);

  /// Cancela una invitación pendiente.
  Future<Result<void>> cancel(String establishmentId, String invitationId);

  /// Quita a una persona del equipo.
  Future<Result<void>> removeMember(String establishmentId, String userId);

  /// Muestra a qué campo y con qué rol se suma [code], sin consumirlo.
  Future<Result<InvitationPreview>> preview(String code);

  /// Canjea [code] y agrega el establecimiento al catálogo del celular.
  Future<Result<EstablishmentMembership>> accept(String code);
}
