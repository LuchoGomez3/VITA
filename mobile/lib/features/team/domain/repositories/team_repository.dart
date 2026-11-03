import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';

/// Equipo de un establecimiento e invitaciones por código (adr-0012).
///
/// Política online implementada, pendiente de validación del PO (ADR-0012): invitar manda un email y
/// canjear necesita que el servidor valide el código. La lista se cachea para
/// verla sin conexión.
abstract interface class TeamRepository {
  /// Lee la membresía local sin exponer storage al dominio ni a la UI.
  Future<Result<EstablishmentMembership?>> findEstablishment(String establishmentId);

  /// Último equipo guardado en el celular para [establishmentId], si hay.
  Future<Result<TeamSnapshot?>> readCached(String establishmentId);

  /// Trae el equipo del servidor y lo guarda en el celular.
  Future<Result<TeamSnapshot>> refresh(String establishmentId);

  /// Invita a [email] con [role]. Devuelve el código en claro esta única vez.
  Future<Result<TeamMutation<CreatedInvitation>>> invite(
    String establishmentId, {
    required String email,
    required UserRole role,
  });

  /// Genera un código nuevo (devuelto en claro) y reenvía el email.
  Future<Result<TeamMutation<CreatedInvitation>>> resend(String establishmentId, String invitationId);

  /// Cancela una invitación pendiente.
  Future<Result<TeamMutation<void>>> cancel(String establishmentId, String invitationId);

  /// Quita a una persona del equipo.
  Future<Result<TeamMutation<void>>> removeMember(String establishmentId, String userId);

  /// Muestra a qué campo y con qué rol se suma [code], sin consumirlo.
  Future<Result<InvitationPreview>> preview(String code);

  /// Canjea [code] y agrega el establecimiento al catálogo del celular.
  Future<Result<TeamAcceptance>> accept(String code);
}
