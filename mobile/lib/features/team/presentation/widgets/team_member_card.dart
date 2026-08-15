import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/presentation/mock/team_mock.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';

/// Card de un miembro del equipo: avatar, nombre, estado, email, rol y
/// alcance opcional.
class TeamMemberCard extends StatelessWidget {
  /// Crea la card a partir de un miembro mock.
  const TeamMemberCard({required this.member, super.key});

  /// Miembro representado.
  final TeamMemberMock member;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusTone) = switch (member.status) {
      TeamMemberStatus.active => (TeamStrings.activeStatusLabel, AppStatusChipTone.success),
      TeamMemberStatus.invited => (TeamStrings.invitedStatusLabel, AppStatusChipTone.warn),
    };

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
              backgroundColor: member.avatarColor,
              child: Text(member.initials, style: AppTypography.avatarInitials),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(member.name, style: AppTypography.mediumEmphasis),
                      ),
                      AppStatusChip(label: statusLabel, tone: statusTone),
                    ],
                  ),
                  Text(
                    member.email,
                    style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppStatusChip(label: teamRoleLabel(member.role)),
                  if (member.scopeNote != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      member.scopeNote!,
                      style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
