import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// "Invitación creada" (`InvCodigoGenerado`): el código para compartir por otro
/// medio si el email no llega. Es la única vez que se ve: si se pierde, se
/// reenvía la invitación y sale uno nuevo.
class InvitationCreatedPage extends StatefulWidget {
  /// Crea la pantalla para [created].
  const InvitationCreatedPage({
    required this.created,
    required this.establishmentName,
    required this.cancelInvitation,
    super.key,
  });

  /// Invitación con su código en claro.
  final CreatedInvitation created;

  /// Nombre del campo, para el mensaje que se comparte.
  final String establishmentName;

  /// Cancela la invitación (online-only).
  final Future<Result<void>> Function() cancelInvitation;

  @override
  State<InvitationCreatedPage> createState() => _InvitationCreatedPageState();
}

class _InvitationCreatedPageState extends State<InvitationCreatedPage> {
  bool _cancelling = false;

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
    setState(() => _cancelling = true);
    final result = await widget.cancelInvitation();
    if (!mounted) {
      return;
    }
    setState(() => _cancelling = false);
    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case Success():
        messenger.showSnackBar(const SnackBar(content: Text(TeamStrings.cancelledNotice)));
        context.pop(true);
      case Failure(:final error):
        messenger.showSnackBar(SnackBar(content: Text(TeamStrings.error(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    _invitation.emailSent ? TeamStrings.createdExplanation : TeamStrings.createdWithoutEmailExplanation,
                    style: AppTypography.secondaryEmphasis,
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                        child: AppOutlinedButton(
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
                    onPressed: _cancelling ? null : () => unawaited(_cancel()),
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    child: Text(_cancelling ? TeamStrings.cancellingCta : TeamStrings.cancelAction),
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
                        tone: AppStatusChipTone.warn,
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
