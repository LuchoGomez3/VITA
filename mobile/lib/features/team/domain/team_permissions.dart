import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';

/// Permisos locales de gestión; backend valida además identidad y membresía activa.
bool canRemoveTeamMember(UserRole actor, TeamMember member) =>
    !member.isHolder && member.role != UserRole.unknown && actor.canRemove(member.role);

/// Un rol desconocido nunca puede gestionar invitaciones.
bool canManageTeamInvitation(UserRole actor, TeamInvitation invitation) =>
    actor.assignableRoles.contains(invitation.role);
