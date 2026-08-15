import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/presentation/mock/team_mock.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:go_router/go_router.dart';

/// Ícono representativo de cada [TeamRole] en el selector de invitación.
IconData _roleIcon(TeamRole role) => switch (role) {
  TeamRole.owner => Icons.workspace_premium,
  TeamRole.administrator => Icons.admin_panel_settings,
  TeamRole.capataz => Icons.agriculture,
  TeamRole.assetManager => Icons.inventory_2,
  TeamRole.veterinarian => Icons.medical_services,
  TeamRole.externalBuyer => Icons.visibility,
};

/// Pantalla de invitación de un nuevo miembro del equipo, con selector de
/// rol.
///
/// Réplica visual estática del diseño `EquipoInvitar` (ver
/// `.claude/specs/gestion-de-equipo.md`); a diferencia del diseño (que sólo
/// muestra 5 roles), lista los 6 roles reales definidos en CLAUDE.md. El
/// email y el envío son mock, sin validación ni backend todavía.
class InviteTeamMemberPage extends StatefulWidget {
  /// Crea la pantalla de invitación.
  const InviteTeamMemberPage({super.key});

  @override
  State<InviteTeamMemberPage> createState() => _InviteTeamMemberPageState();
}

class _InviteTeamMemberPageState extends State<InviteTeamMemberPage> {
  final _emailController = TextEditingController(text: teamInviteEmailMock);
  TeamRole _selectedRole = teamInviteDefaultRole;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendInvite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(TeamStrings.inviteSentToast)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _InviteTeamMemberHeader(onClose: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
                children: [
                  AppTextFormField(
                    title: TeamStrings.inviteEmailFieldLabel,
                    hintText: TeamStrings.inviteEmailFieldLabel,
                    controller: _emailController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(TeamStrings.inviteRoleSectionTitle, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  for (final option in teamRoleOptionsMock) ...[
                    AppSelectableCard<TeamRole>(
                      value: option.role,
                      groupValue: _selectedRole,
                      title: option.label,
                      subtitle: option.description,
                      icon: _roleIcon(option.role),
                      onChanged: (role) => setState(() => _selectedRole = role),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppFilledButton(
                label: TeamStrings.sendInviteCta,
                onPressed: _handleSendInvite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteTeamMemberHeader extends StatelessWidget {
  const _InviteTeamMemberHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: TeamStrings.inviteCloseTooltip,
            onPressed: onClose,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(TeamStrings.inviteTitle, style: AppTypography.appBarTitle),
        ],
      ),
    );
  }
}
