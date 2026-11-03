import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/invitation_created_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// "Invitación creada" (`InvCodigoGenerado`): el código para compartir por otro
/// medio si el email no llega. Es la única vez que se ve: si se pierde, se
/// reenvía la invitación y sale uno nuevo.
class InvitationCreatedPage extends StatelessWidget {
  /// Crea la pantalla para [created].
  const InvitationCreatedPage({
    required this.created,
    required this.establishmentName,
    required this.createCubit,
    super.key,
  });

  /// Invitación con su código en claro.
  final CreatedInvitation created;

  /// Nombre del campo, para el mensaje que se comparte.
  final String establishmentName;

  /// Cancela la invitación (online-only).
  final InvitationCreatedCubit Function() createCubit;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createCubit(),
    child: _InvitationCreatedView(created: created, establishmentName: establishmentName),
  );
}

class _InvitationCreatedView extends StatefulWidget {
  const _InvitationCreatedView({required this.created, required this.establishmentName});
  final CreatedInvitation created;
  final String establishmentName;
  @override
  State<_InvitationCreatedView> createState() => _InvitationCreatedPageState();
}

class _InvitationCreatedPageState extends State<_InvitationCreatedView> {
  TeamInvitation get _invitation => widget.created.invitation;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.created.code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(TeamStrings.codeCopied)));
    }
  }

  Future<void> _share() => SharePlus.instance.share(
    ShareParams(text: TeamStrings.shareMessage(widget.establishmentName, widget.created.code, _invitation.email)),
  );

  Future<void> _cancel() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(TeamStrings.cancelConfirmTitle(_invitation.email)),
            content: const Text(TeamStrings.cancelConfirmMessage),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text(TeamStrings.keepCta)),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(TeamStrings.confirmCancelCta),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }
    await context.read<InvitationCreatedCubit>().cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvitationCreatedCubit, ResultState<TeamMutation<void>>>(
      listener: (context, state) {
        switch (state) {
          case Data<TeamMutation<void>>(:final data):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  data.persistenceError == null ? TeamStrings.cancelledNotice : TeamStrings.mutationStorageWarning,
                ),
              ),
            );
            context.pop(data);
          case ResultError<TeamMutation<void>>(:final error):
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(TeamStrings.error(error))));
          default:
            break;
        }
      },
      builder: (context, state) {
        final cancelling = state is Loading<TeamMutation<void>>;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: TeamStrings.closeTooltip,
                        onPressed: () => context.pop(true),
                      ),
                      const Expanded(
                        child: Text(
                          TeamStrings.createdTitle,
                          textAlign: TextAlign.center,
                          style: AppTypography.appBarTitle,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      _InviteeCard(invitation: _invitation),
                      const SizedBox(height: AppSpacing.md),
                      // Si el email no salió, se avisa arriba de todo: el código
                      // sirve igual y hay que mandarlo por otro medio.
                      if (!_invitation.emailSent) ...[
                        const _EmailNotSentBanner(),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              Text(
                                TeamStrings.codeLabel.toUpperCase(),
                                style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              SelectableText(
                                widget.created.code,
                                style: AppTypography.monoValueEmphasis.copyWith(fontSize: 40, letterSpacing: 5),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                TeamStrings.codeValidity(_invitation.expiresAt),
                                style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_invitation.emailSent) ...[
                        const Text(TeamStrings.createdExplanation, style: AppTypography.secondaryEmphasis),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: AppOutlinedButton(
                              label: TeamStrings.copyCta,
                              icon: const Icon(Icons.copy_outlined),
                              onPressed: () => unawaited(_copy()),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            // Sin email, compartir es el camino principal.
                            child: _invitation.emailSent
                                ? AppOutlinedButton(
                                    label: TeamStrings.shareCta,
                                    icon: const Icon(Icons.share_outlined),
                                    onPressed: () => unawaited(_share()),
                                  )
                                : AppFilledButton(
                                    label: TeamStrings.shareCta,
                                    icon: const Icon(Icons.share_outlined),
                                    onPressed: () => unawaited(_share()),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: Column(
                    children: [
                      AppFilledButton(label: TeamStrings.doneCta, onPressed: () => context.pop(true)),
                      const SizedBox(height: AppSpacing.xs),
                      TextButton(
                        onPressed: cancelling ? null : () => unawaited(_cancel()),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: Text(cancelling ? TeamStrings.cancellingCta : TeamStrings.cancelAction),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmailNotSentBanner extends StatelessWidget {
  const _EmailNotSentBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.syncPendingContainer,
        border: Border.all(color: AppColors.syncPending),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.mail_lock_outlined, color: AppColors.syncPending, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TeamStrings.emailNotSentTitle,
                    style: AppTypography.mediumEmphasis.copyWith(color: AppColors.syncPending),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    TeamStrings.createdWithoutEmailExplanation,
                    style: AppTypography.smallEmphasis.copyWith(color: AppColors.syncPending),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteeCard extends StatelessWidget {
  const _InviteeCard({required this.invitation});

  final TeamInvitation invitation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.backgroundTertiary,
              child: Text(
                invitation.email.substring(0, 2).toUpperCase(),
                style: AppTypography.avatarInitials.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitation.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.mediumEmphasis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      AppStatusChip(label: UserRoleStrings.name(invitation.role)),
                      const AppStatusChip(
                        label: TeamStrings.pendingStatus,
                        tone: AppStatusChipTone.warning,
                        showDot: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
