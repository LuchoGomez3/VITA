import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';

/// Acción disponible en el menú de una [TeamPersonCard].
typedef TeamCardAction = ({String label, IconData icon, VoidCallback onSelected});

/// Card de una persona del equipo o de una invitación, como en `EquipoScreen`:
/// avatar de iniciales, nombre, estado, email, rol y una nota opcional.
class TeamPersonCard extends StatelessWidget {
  /// Crea la card.
  const TeamPersonCard({
    required this.title,
    required this.subtitle,
    required this.role,
    required this.statusLabel,
    required this.statusTone,
    super.key,
    this.initials,
    this.avatarColor,
    this.note,
    this.noteIsWarning = false,
    this.actions = const [],
    this.isBusy = false,
  });

  /// Nombre de la persona, o el email si todavía no aceptó.
  final String title;

  /// Segunda línea: el email del miembro o el estado de la invitación.
  final String subtitle;

  /// Rol en el establecimiento.
  final UserRole role;

  /// Texto del chip de estado.
  final String statusLabel;

  /// Tono del chip de estado.
  final AppStatusChipTone statusTone;

  /// Iniciales del avatar; sin iniciales se muestra un sobre.
  final String? initials;

  /// Color del avatar.
  final Color? avatarColor;

  /// Nota debajo del rol (titular, vencimiento, email que no salió).
  final String? note;

  /// Si la nota es una advertencia.
  final bool noteIsWarning;

  /// Acciones del menú; sin acciones no hay menú.
  final List<TeamCardAction> actions;

  /// Si hay una acción en curso sobre esta card.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final visibleNote = note;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor ?? AppColors.textHint,
              child: initials == null
                  ? const Icon(Icons.mail_outline, color: AppColors.onPrimary, size: 20)
                  : Text(initials!, style: AppTypography.avatarInitials),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.mediumEmphasis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      AppStatusChip(label: statusLabel, tone: statusTone),
                    ],
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppStatusChip(label: UserRoleStrings.name(role)),
                  if (visibleNote != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      visibleNote,
                      style: AppTypography.smallEmphasis.copyWith(
                        color: noteIsWarning ? AppColors.syncPending : AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isBusy)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (actions.isNotEmpty)
              PopupMenuButton<int>(
                tooltip: TeamStrings.actionsTooltip,
                icon: const Icon(Icons.more_vert),
                onSelected: (index) => actions[index].onSelected(),
                itemBuilder: (context) => [
                  for (final (index, action) in actions.indexed)
                    PopupMenuItem<int>(
                      value: index,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(action.icon, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(child: Text(action.label)),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
