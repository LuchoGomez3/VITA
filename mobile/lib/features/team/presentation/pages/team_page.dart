import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
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
  Widget build(BuildContext context) => BlocConsumer<TeamCubit, TeamState>(
    listenWhen: (previous, current) => previous.action != current.action || previous.error != current.error,
    listener: (context, state) {
      final created = state.created;
      if (created != null) {
        final cubit = context.read<TeamCubit>()..consumeCreated();
        unawaited(_openCreated(context, cubit, created));
        return;
      }
      final message = state.persistenceError != null
          ? TeamStrings.mutationStorageWarning
          : state.error != null
          ? TeamStrings.error(state.error!)
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
    },
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
        body: SafeArea(
          child: _TeamBody(
            state: state,
            onRefresh: cubit.refresh,
            onRemove: (member) async {
              if (await _confirm(
                    context,
                    title: TeamStrings.removeConfirmTitle('${member.firstName} ${member.lastName}'.trim()),
                    message: TeamStrings.removeConfirmMessage,
                    cta: TeamStrings.confirmRemoveCta,
                  ) &&
                  context.mounted) {
                await cubit.remove(member);
              }
            },
            onCancel: (invitation) async {
              if (await _confirm(
                    context,
                    title: TeamStrings.cancelConfirmTitle(invitation.email),
                    message: TeamStrings.cancelConfirmMessage,
                    cta: TeamStrings.confirmCancelCta,
                  ) &&
                  context.mounted) {
                await cubit.cancel(invitation);
              }
            },
            onResend: cubit.resend,
          ),
        ),
      );
    },
  );

  Future<void> _openInvite(BuildContext context, TeamCubit cubit) async {
    final mutation = await context.push<TeamMutation<CreatedInvitation>>(
      AppRoutes.teamInviteFor(cubit.establishmentId),
    );
    if (mutation == null || !context.mounted) return;
    cubit.invitationCreated(mutation);
    if (mutation.persistenceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(TeamStrings.mutationStorageWarning)));
    }
    await _openCreated(context, cubit, mutation.value);
  }

  Future<void> _openCreated(BuildContext context, TeamCubit cubit, CreatedInvitation created) async {
    final result = await context.push<Object?>(
      AppRoutes.teamInvitationCreatedFor(cubit.establishmentId),
      extra: (created: created, establishmentName: cubit.state.establishment?.name ?? ''),
    );
    if (!context.mounted) return;
    if (result is TeamMutation<void>) cubit.reconcileMutation(result);
    await cubit.refresh();
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String cta,
  }) async =>
      await showDialog<bool>(
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

class _TeamBody extends StatelessWidget {
  const _TeamBody({
    required this.state,
    required this.onRefresh,
    required this.onRemove,
    required this.onCancel,
    required this.onResend,
  });
  final TeamState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function(TeamMember) onRemove;
  final Future<void> Function(TeamInvitation) onCancel;
  final Future<void> Function(TeamInvitation) onResend;

  @override
  Widget build(BuildContext context) {
    if (state.establishmentMissing) return const _Message(text: TeamStrings.establishmentMissing);
    final snapshot = state.snapshot;
    if (snapshot == null) {
      if (state.isLoading) return const Center(child: CircularProgressIndicator());
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (state.isOffline) const _OfflineBanner(fetchedAt: null),
            _Message(text: state.isOffline ? TeamStrings.emptyOffline : TeamStrings.loadFailed),
            Center(
              child: AppOutlinedButton(label: TeamStrings.retryCta, onPressed: onRefresh),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl * 3),
        children: [
          if (state.isOffline) ...[
            _OfflineBanner(fetchedAt: snapshot.fetchedAt),
            const SizedBox(height: AppSpacing.md),
          ],
          if (!snapshot.isComplete) const _Message(text: TeamStrings.partialCache),
          if (state.persistenceError != null) const _Message(text: TeamStrings.mutationStorageWarning),
          Text(TeamStrings.membersSection(snapshot.members.length), style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.sm),
          for (final member in snapshot.members) ...[
            _MemberCard(
              member: member,
              canRemove: state.canRemove(member),
              isBusy: state.busyId == member.userId,
              onRemove: () => onRemove(member),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (snapshot.invitations.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(TeamStrings.invitationsSection(snapshot.invitations.length), style: AppTypography.pageTitle),
            const SizedBox(height: AppSpacing.sm),
            for (final invitation in snapshot.invitations) ...[
              _InvitationCard(
                invitation: invitation,
                canManage: state.canManageInvitation(invitation),
                isBusy: state.busyId == invitation.id,
                onResend: () => onResend(invitation),
                onCancel: () => onCancel(invitation),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.canRemove, required this.isBusy, required this.onRemove});
  final TeamMember member;
  final bool canRemove;
  final bool isBusy;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => TeamPersonCard(
    title: '${member.firstName} ${member.lastName}'.trim(),
    subtitle: member.email,
    role: member.role,
    statusLabel: TeamStrings.activeStatus,
    statusTone: AppStatusChipTone.success,
    initials: _initials(member),
    avatarColor: _color(member.headerColor),
    note: member.isHolder ? TeamStrings.holderNote : null,
    isBusy: isBusy,
    actions: [
      if (canRemove) (label: TeamStrings.removeAction, icon: Icons.person_remove_outlined, onSelected: onRemove),
    ],
  );
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

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.canManage,
    required this.isBusy,
    required this.onResend,
    required this.onCancel,
  });
  final TeamInvitation invitation;
  final bool canManage;
  final bool isBusy;
  final VoidCallback onResend;
  final VoidCallback onCancel;
  @override
  Widget build(BuildContext context) => TeamPersonCard(
    title: invitation.email,
    subtitle: TeamStrings.invitationSubtitle,
    role: invitation.role,
    statusLabel: invitation.isExpired ? TeamStrings.expiredStatus : TeamStrings.invitedStatus,
    statusTone: invitation.isExpired ? AppStatusChipTone.neutral : AppStatusChipTone.warning,
    note: invitation.isExpired
        ? TeamStrings.expiredOn(invitation.expiresAt)
        : (invitation.emailSent ? TeamStrings.expiresOn(invitation.expiresAt) : TeamStrings.emailNotSent),
    noteIsWarning: invitation.isExpired || !invitation.emailSent,
    isBusy: isBusy,
    actions: [
      if (canManage) ...[
        (label: TeamStrings.resendAction, icon: Icons.forward_to_inbox_outlined, onSelected: onResend),
        (label: TeamStrings.cancelAction, icon: Icons.cancel_outlined, onSelected: onCancel),
      ],
    ],
  );
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
