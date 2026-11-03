import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:frontend_mayoral/features/team/presentation/widgets/code_boxes.dart';
import 'package:go_router/go_router.dart';

/// "Sumarme a un establecimiento": ingresar el código (`InvIngresarCodigo`),
/// error (`InvError`), confirmar (`InvConfirmar`) y éxito (`InvExito`).
/// Online-only.
class JoinEstablishmentPage extends StatelessWidget {
  /// Crea la pantalla.
  const JoinEstablishmentPage({required this.createCubit, super.key});

  /// Construye el Cubit (inyectado para los tests).
  final JoinEstablishmentCubit Function() createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => createCubit(), child: const _JoinView());
  }
}

class _JoinView extends StatelessWidget {
  const _JoinView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JoinEstablishmentCubit, JoinEstablishmentState>(
      // El error de un código se ve en la pantalla; el del canje (ya confirmado)
      // va en un aviso porque la confirmación queda arriba para reintentar.
      listenWhen: (previous, current) => current.step == JoinStep.confirm && current.error != null,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(TeamStrings.error(state.error!)))),
      builder: (context, state) {
        if (state.step == JoinStep.recovery) return _Recovery(state: state);
        if (state.step == JoinStep.joined) {
          return _Joined(state: state);
        }
        final cubit = context.read<JoinEstablishmentCubit>();
        final confirming = state.step == JoinStep.confirm || state.step == JoinStep.joining;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            centerTitle: true,
            title: const Text(TeamStrings.joinTitle, style: AppTypography.appBarTitle),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      if (confirming)
                        _ConfirmContent(state: state)
                      else
                        _EnterContent(state: state, onChanged: cubit.edit, onCheck: cubit.check),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: confirming
                      ? _ConfirmActions(state: state, onConfirm: cubit.confirm, onClear: cubit.clear)
                      : _EnterActions(
                          state: state,
                          onCheck: cubit.check,
                          onDismissError: cubit.dismissError,
                          onClear: cubit.clear,
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

class _EnterContent extends StatelessWidget {
  const _EnterContent({required this.state, required this.onChanged, required this.onCheck});
  final JoinEstablishmentState state;
  final ValueChanged<String> onChanged;
  final Future<void> Function() onCheck;
  @override
  Widget build(BuildContext context) {
    final error = state.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(TeamStrings.enterCodeTitle, style: AppTypography.bigTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(
          error == null ? TeamStrings.enterCodeIntro : TeamStrings.enterCodeIntroShort,
          style: AppTypography.secondaryEmphasis,
        ),
        const SizedBox(height: AppSpacing.xl),
        CodeBoxes(
          code: state.code,
          length: JoinEstablishmentCubit.codeLength,
          state: error == null ? CodeBoxesState.idle : CodeBoxesState.invalid,
          onChanged: state.step == JoinStep.checking ? null : onChanged,
          onSubmitted: () => unawaited(onCheck()),
          autofocus: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (error == null) ...[
          const Text(TeamStrings.caseInsensitive, textAlign: TextAlign.center, style: AppTypography.formFieldHelper),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: state.step == JoinStep.checking ? null : () => unawaited(_paste(context)),
            icon: const Icon(Icons.content_paste),
            label: const Text(TeamStrings.pasteCta),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _Note(icon: Icons.cloud_outlined, text: TeamStrings.onlineNote),
        ] else ...[
          const SizedBox(height: AppSpacing.sm),
          _ErrorBanner(error: error),
          if (_remainingAttempts(error) case final remaining?) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              TeamStrings.remainingAttempts(remaining),
              textAlign: TextAlign.center,
              style: AppTypography.formFieldHelper,
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _paste(BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (context.mounted && data?.text != null) onChanged(data!.text!);
  }

  static int? _remainingAttempts(DomainException error) {
    final failure = error.reason;
    return failure is TeamFailure ? failure.remainingAttempts : null;
  }
}

class _EnterActions extends StatelessWidget {
  const _EnterActions({
    required this.state,
    required this.onCheck,
    required this.onDismissError,
    required this.onClear,
  });
  final JoinEstablishmentState state;
  final Future<void> Function() onCheck;
  final VoidCallback onDismissError;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    if (state.error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFilledButton(
            label: TeamStrings.retryCodeCta,
            icon: const Icon(Icons.refresh),
            // Sin conexión se reintenta el mismo código; si el servidor lo
            // rechazó, se vuelve a la edición con lo escrito.
            onPressed: state.canRetryValidation ? () => unawaited(onCheck()) : onDismissError,
          ),
          TextButton(onPressed: onClear, child: const Text(TeamStrings.clearCodeCta)),
        ],
      );
    }
    return AppFilledButton(
      label: TeamStrings.validateCta,
      isLoading: state.step == JoinStep.checking,
      loadingLabel: TeamStrings.checkingCta,
      onPressed: state.isComplete ? () => unawaited(onCheck()) : null,
    );
  }
}

class _ConfirmContent extends StatelessWidget {
  const _ConfirmContent({required this.state});
  final JoinEstablishmentState state;
  @override
  Widget build(BuildContext context) {
    final preview = state.preview!;
    final place = [preview.locality, preview.province].whereType<String>().where((s) => s.isNotEmpty).join(', ');
    final abilities = TeamStrings.roleAbilities(preview.role);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CodeBoxes(
          code: state.code,
          length: JoinEstablishmentCubit.codeLength,
          state: CodeBoxesState.valid,
          compact: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xxs),
            Flexible(
              child: Text(
                TeamStrings.validCode,
                textAlign: TextAlign.center,
                style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(TeamStrings.invitedTo, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(preview.establishmentName, style: AppTypography.pageTitle),
                if (preview.renspa case final renspa? when renspa.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(TeamStrings.renspa(renspa), style: AppTypography.monoValue.copyWith(color: AppColors.textHint)),
                ],
                if (place.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 14, color: AppColors.textHint),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(place, style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint)),
                      ),
                    ],
                  ),
                ],
                const Divider(height: AppSpacing.lg),
                _InfoRow(
                  label: TeamStrings.invitedByLabel,
                  value: Text(
                    TeamStrings.invitedByValue(preview.invitedBy, preview.invitedByRole),
                    textAlign: TextAlign.right,
                    style: AppTypography.smallEmphasis,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _InfoRow(
                  label: TeamStrings.yourRoleLabel,
                  value: AppStatusChip(label: UserRoleStrings.name(preview.role)),
                ),
                const SizedBox(height: AppSpacing.xs),
                _InfoRow(
                  label: TeamStrings.emailRowLabel,
                  value: Text(
                    preview.email,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTypography.smallEmphasis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(TeamStrings.abilitiesTitle(preview.role), style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.sm),
        for (final ability in abilities.can) _Ability(text: ability, allowed: true),
        for (final ability in abilities.cannot) _Ability(text: ability, allowed: false),
      ],
    );
  }
}

class _ConfirmActions extends StatelessWidget {
  const _ConfirmActions({required this.state, required this.onConfirm, required this.onClear});
  final JoinEstablishmentState state;
  final Future<void> Function() onConfirm;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    final joining = state.step == JoinStep.joining;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilledButton(
          label: TeamStrings.joinEstablishmentCta(state.preview!.establishmentName),
          icon: const Icon(Icons.check),
          isLoading: joining,
          loadingLabel: TeamStrings.joiningCta,
          onPressed: () => unawaited(onConfirm()),
        ),
        TextButton(onPressed: joining ? null : onClear, child: const Text(TeamStrings.notMyInvitationCta)),
      ],
    );
  }
}

class _Recovery extends StatelessWidget {
  const _Recovery({required this.state});
  final JoinEstablishmentState state;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const AppHeader(title: TeamStrings.joinTitle),
    body: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Text(TeamStrings.acceptanceRecovery),
          const SizedBox(height: AppSpacing.md),
          if (state.download is ResultError) const Text(TeamStrings.downloadFailed),
          AppFilledButton(
            label: TeamStrings.recoverCta,
            isLoading: state.download is Loading || state.acceptance is Loading,
            onPressed: context.read<JoinEstablishmentCubit>().recover,
          ),
        ],
      ),
    ),
  );
}

class _Joined extends StatelessWidget {
  const _Joined({required this.state});

  final JoinEstablishmentState state;

  @override
  Widget build(BuildContext context) {
    final preview = state.preview;
    final name = state.joined!.name;
    final sync = state.dataSync;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 4),
                        ),
                        child: const Icon(Icons.check, size: 56, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        TeamStrings.joinedTitle(name),
                        textAlign: TextAlign.center,
                        style: AppTypography.successTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        TeamStrings.joinedSubtitle(state.joined!.role, preview?.invitedBy ?? ''),
                        textAlign: TextAlign.center,
                        style: AppTypography.successSubtitle,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppSurfaceCard(
                        elevation: 0,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sync == JoinDataSync.running ? TeamStrings.downloadingData : TeamStrings.downloadedTitle,
                              style: AppTypography.mediumEmphasis,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                // Sin porcentaje: la sincronización inicial no lo informa.
                                value: sync == JoinDataSync.running ? null : 1,
                                minHeight: 8,
                                color: sync == JoinDataSync.failed ? AppColors.syncPending : AppColors.primary,
                                backgroundColor: AppColors.backgroundTertiary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              switch (sync) {
                                JoinDataSync.failed => TeamStrings.downloadFailed,
                                JoinDataSync.done => TeamStrings.downloadDone,
                                _ => TeamStrings.downloadRunning,
                              },
                              style: AppTypography.formFieldHelper,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.persistence is ResultError<void>) ...[
                const Text(TeamStrings.acceptedStorageWarning),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (state.dataSync == JoinDataSync.failed)
                AppOutlinedButton(
                  label: TeamStrings.recoverCta,
                  onPressed: context.read<JoinEstablishmentCubit>().recover,
                ),
              AppFilledButton(
                label: TeamStrings.goHomeCta,
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  // Primero `pop`: completa el `push` de Perfil para que recargue
                  // la lista con el campo nuevo. `go` solo descartaría la pantalla
                  // sin avisarle, y Perfil seguiría mostrando la lista vieja.
                  final router = GoRouter.of(context);
                  if (router.canPop()) context.pop(true);
                  router.go(AppRoutes.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.error});

  final DomainException error;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        border: Border.all(color: AppColors.error),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TeamStrings.codeErrorTitle(error),
                    style: AppTypography.mediumEmphasis.copyWith(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(TeamStrings.error(error), style: AppTypography.smallEmphasis.copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Text(label, style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint));
        if (constraints.maxWidth < 280 || MediaQuery.textScalerOf(context).scale(1) > 1.3) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: AppSpacing.xxs),
              Align(alignment: Alignment.centerLeft, child: value),
            ],
          );
        }
        return Row(
          children: [
            title,
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: value),
            ),
          ],
        );
      },
    );
  }
}

class _Ability extends StatelessWidget {
  const _Ability({required this.text, required this.allowed});

  final String text;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(allowed ? Icons.check : Icons.close, size: 18, color: allowed ? AppColors.primary : AppColors.textHint),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.secondaryEmphasis.copyWith(
                color: allowed ? AppColors.textPrimary : AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(text, style: AppTypography.smallEmphasis)),
          ],
        ),
      ),
    );
  }
}
