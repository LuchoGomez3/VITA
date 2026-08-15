import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/presentation/mock/team_mock.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:frontend_mayoral/features/team/presentation/widgets/team_member_card.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de listado de miembros del equipo, con acceso a invitar uno
/// nuevo.
///
/// Réplica visual estática del diseño `EquipoScreen` (ver
/// `.claude/specs/gestion-de-equipo.md`); los usuarios son mock fijo, sin
/// backend de invitación todavía.
class TeamPage extends StatelessWidget {
  /// Crea la pantalla de listado de equipo.
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: TeamStrings.title),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.teamInvite),
        label: const Text(TeamStrings.inviteFabLabel),
        icon: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl * 2),
          children: [
            Text(
              TeamStrings.usersSectionTitle(teamMembersMock.length),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final member in teamMembersMock) ...[
              TeamMemberCard(member: member),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
