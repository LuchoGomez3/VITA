import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/team_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:frontend_mayoral/features/team/presentation/widgets/team_person_card.dart';
import 'package:go_router/go_router.dart';

/// Usuarios del establecimiento (`EquipoScreen`): activos e invitaciones
/// pendientes. Se entra desde la ficha del establecimiento en Perfil.
///
/// Sin conexión muestra el último equipo guardado y deshabilita las acciones,
/// que necesitan al servidor (adr-0012).
class TeamPage extends StatelessWidget {
  /// Crea la pantalla para [establishmentId].
  const TeamPage({required this.establishmentId, required this.createCubit, super.key});

  /// Establecimiento cuyo equipo se muestra.
  final String establishmentId;

  /// Construye el Cubit (inyectado para los tests).
  final TeamCubit Function(String establishmentId) createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit(establishmentId)..load(),
      child: const _TeamView(),
    );
  }
}

class _TeamView extends StatelessWidget {
  const _TeamView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamCubit, TeamState>(
      listenWhen: (previous, current) => current.notice != null || current.error != null,
      listener: _showFeedback,
      builder: (context, state) {
        final cubit = context.read<TeamCubit>();
        return Scaffold(
          appBar: AppHeader(title: TeamStrings.title, headline: state.establishment?.name),
          floatingActionButton: state.canManage
              ? FloatingActionButton.extended(
                  onPressed: state.actionsEnabled ? () => _openInvite(context, cubit) : null,
                  backgroundColor: state.actionsEnabled ? null : AppColors.backgroundTertiary,
                  label: const Text(TeamStrings.inviteFab),
                  icon: const Icon(Icons.add),
                )
              : null,
          body: SafeArea(child: _body(context, state, cubit)),
        );
      },
    );
  }

  Widget _body(BuildContext context, TeamState state, TeamCubit cubit) {
    if (state.establishmentMissing) {
      return const _Message(text: TeamStrings.establishmentMissing);
    }
    final snapshot = state.snapshot;
    if (snapshot == null) {
      // Cargando: todavía no se resolvió el establecimiento o se está pidiendo.
      if (state.isLoading || state.establishment == null) {
        return const Center(child: CircularProgressIndicator());
      }
      // No hay nada guardado y no se pudo traer: aviso y reintento, nunca un
      // spinner eterno.
      return RefreshIndicator(
        onRefresh: cubit.refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (state.isOffline) const _OfflineBanner(fetchedAt: null),
            _Message(text: state.isOffline ? TeamStrings.emptyOffline : TeamStrings.loadFailed),
            Center(
              child: AppOutlinedButton(label: TeamStrings.retryCta, onPressed: cubit.refresh),
            ),
          ],
        ),
      );
    }

    final myRole = state.establishment?.role ?? UserRole.unknown;
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl * 3),
        children: [
          if (state.isOffline) ...[
            _OfflineBanner(fetchedAt: snapshot.fetchedAt),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(TeamStrings.membersSection(snapshot.members.length), style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.sm),
          for (final member in snapshot.members) ...[
            _memberCard(context, state, cubit, member, myRole),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (snapshot.invitations.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(TeamStrings.invitationsSection(snapshot.invitations.length), style: AppTypography.pageTitle),
            const SizedBox(height: AppSpacing.sm),
            for (final invitation in snapshot.invitations) ...[
              _invitationCard(context, state, cubit, invitation, myRole),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }

  Widget _memberCard(BuildContext context, TeamState state, TeamCubit cubit, TeamMember member, UserRole myRole) {
    final canRemove = state.actionsEnabled && !member.isHolder && myRole.canRemove(member.role);
    return TeamPersonCard(
      title: '${member.firstName} ${member.lastName}'.trim(),
      subtitle: member.email,
      role: member.role,
      statusLabel: TeamStrings.activeStatus,
      statusTone: AppStatusChipTone.success,
      initials: _initials(member),
      avatarColor: _color(member.headerColor),
      note: member.isHolder ? TeamStrings.holderNote : null,
      isBusy: state.busyId == member.userId,
      actions: [
        if (canRemove)
          (
            label: TeamStrings.removeAction,
            icon: Icons.person_remove_outlined,
            onSelected: () async {
              final name = '${member.firstName} ${member.lastName}'.trim();
              if (await _confirm(
                context,
                title: TeamStrings.removeConfirmTitle(name),
                message: TeamStrings.removeConfirmMessage,
                cta: TeamStrings.confirmRemoveCta,
              )) {
                await cubit.remove(member);
              }
            },
          ),
      ],
    );
  }

  Widget _invitationCard(
    BuildContext context,
    TeamState state,
    TeamCubit cubit,
    TeamInvitation invitation,
    UserRole myRole,
  ) {
    final canManage = state.actionsEnabled && myRole.assignableRoles.contains(invitation.role);
    return TeamPersonCard(
      title: invitation.email,
      subtitle: TeamStrings.invitationSubtitle,
      role: invitation.role,
      statusLabel: invitation.isExpired ? TeamStrings.expiredStatus : TeamStrings.invitedStatus,
      statusTone: invitation.isExpired ? AppStatusChipTone.neutral : AppStatusChipTone.warn,
      note: invitation.isExpired
          ? TeamStrings.expiredOn(invitation.expiresAt)
          : (invitation.emailSent ? TeamStrings.expiresOn(invitation.expiresAt) : TeamStrings.emailNotSent),
      noteIsWarning: invitation.isExpired || !invitation.emailSent,
      isBusy: state.busyId == invitation.id,
      actions: [
        if (canManage) ...[
          (
            label: TeamStrings.resendAction,
            icon: Icons.forward_to_inbox_outlined,
            onSelected: () => cubit.resend(invitation),
          ),
          (
            label: TeamStrings.cancelAction,
            icon: Icons.cancel_outlined,
            onSelected: () async {
              if (await _confirm(
                context,
                title: TeamStrings.cancelConfirmTitle(invitation.email),
                message: TeamStrings.cancelConfirmMessage,
                cta: TeamStrings.confirmCancelCta,
              )) {
                await cubit.cancel(invitation);
              }
            },
          ),
        ],
      ],
    );
  }

  Future<void> _openInvite(BuildContext context, TeamCubit cubit) async {
    final sent = await context.push<bool>(AppRoutes.teamInviteFor(cubit.establishmentId));
    if (sent ?? false) {
      await cubit.refresh();
    }
  }

  static void _showFeedback(BuildContext context, TeamState state) {
    final error = state.error;
    final message = error != null
        ? TeamStrings.error(error)
        : switch (state.notice) {
            TeamNotice.resent => TeamStrings.resentNotice,
            TeamNotice.resentWithoutEmail => TeamStrings.resentWithoutEmailNotice,
            TeamNotice.cancelled => TeamStrings.cancelledNotice,
            TeamNotice.removed => TeamStrings.removedNotice,
            null => null,
          };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String cta,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text(TeamStrings.keepCta)),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(cta)),
            ],
          ),
        ) ??
        false;
  }

  static String _initials(TeamMember member) {
    final first = member.firstName.trim();
    final last = member.lastName.trim();
    final initials = '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}'.toUpperCase();
    return initials.isEmpty ? member.email[0].toUpperCase() : initials;
  }

  static Color _color(String? hex) {
    final value = hex == null || hex.length != 7 ? null : int.tryParse(hex.substring(1), radix: 16);
    return value == null ? AppColors.primary : Color(0xFF000000 | value);
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.fetchedAt});

  final DateTime? fetchedAt;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.syncPendingContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppColors.syncPending, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                TeamStrings.offlineBanner(fetchedAt),
                style: AppTypography.smallEmphasis.copyWith(color: AppColors.syncPending),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(text, textAlign: TextAlign.center, style: AppTypography.secondaryEmphasis),
    );
  }
}
