import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_draft_validation.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/establishment_register_app_bar_title.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/establishment_register_progress_indicator.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/steps/establishment_register_identification_step.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/steps/establishment_register_location_step.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/steps/establishment_register_renspa_step.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/steps/establishment_register_review_step.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/steps/establishment_register_surface_step.dart';
import 'package:go_router/go_router.dart';

/// Factory usada por composition root/router para construir el BLoC.
typedef RegisterEstablishmentBlocFactory =
    RegisterEstablishmentBloc Function({
      RegisterEstablishmentStep initialStep,
    });

/// Aloja el flujo completo de registro de establecimiento.
class EstablishmentRegisterPage extends StatelessWidget {
  /// Crea el flujo de registro de establecimiento.
  const EstablishmentRegisterPage({
    required this.createBloc,
    this.initialStep = RegisterEstablishmentStep.identification,
    super.key,
  });

  /// Crea el BLoC con dependencias ya resueltas fuera de presentation.
  final RegisterEstablishmentBlocFactory createBloc;

  /// Paso mostrado al abrir el flujo.
  final RegisterEstablishmentStep initialStep;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(initialStep: initialStep),
      child: const _EstablishmentRegisterView(),
    );
  }
}

class _EstablishmentRegisterView extends StatelessWidget {
  const _EstablishmentRegisterView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterEstablishmentBloc, RegisterEstablishmentState>(
      listenWhen: (previous, current) => previous.submitResult != current.submitResult,
      listener: (context, state) {
        switch (state.submitResult) {
          case Data<RegisteredEstablishment>(:final data):
            context.push(
              AppRoutes.establishmentRegisterSuccess,
              extra: data,
            );
          case ResultError<RegisteredEstablishment>(:final error):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(error.message)),
              );
          default:
            break;
        }
      },
      child: BlocBuilder<RegisterEstablishmentBloc, RegisterEstablishmentState>(
        buildWhen: (previous, current) {
          return previous.currentStep != current.currentStep ||
              previous.submitResult != current.submitResult ||
              previous.draft != current.draft;
        },
        builder: (context, state) {
          final isReview = state.currentStep == RegisterEstablishmentStep.review;
          final isStepValid = state.draft.isValidForStep(state.currentStep);

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                icon: Icon(isReview ? Icons.chevron_left : Icons.close),
                onPressed: () => _goBack(context, state.currentStep),
              ),
              actions: const [SizedBox(width: 48)],
              title: isReview
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          EstablishmentRegisterStrings.reviewTitle,
                          style: AppTypography.appBarTitle,
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          EstablishmentRegisterStrings.reviewSubtitle,
                          style: AppTypography.secondaryEmphasis,
                        ),
                      ],
                    )
                  : EstablishmentRegisterAppBarTitle(
                      stepSubtitle: _subtitleFor(state.currentStep),
                    ),
            ),
            body: Column(
              children: [
                if (!isReview)
                  EstablishmentRegisterProgressIndicator(
                    currentStep: state.currentStep.index + 1,
                  ),
                Expanded(
                  child: IndexedStack(
                    index: state.currentStep.index,
                    children: const [
                      EstablishmentRegisterIdentificationStep(),
                      EstablishmentRegisterRenspaStep(),
                      EstablishmentRegisterLocationStep(),
                      EstablishmentRegisterSurfaceStep(),
                      EstablishmentRegisterReviewStep(),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _EstablishmentRegisterNavigation(
              currentStep: state.currentStep,
              isSubmitting: state.submitResult is Loading<RegisteredEstablishment>,
              isStepValid: isStepValid,
              onBack: () => _goBack(context, state.currentStep),
              onNext: () => _goNext(context, state.currentStep),
            ),
          );
        },
      ),
    );
  }

  static String _subtitleFor(RegisterEstablishmentStep step) {
    return switch (step) {
      RegisterEstablishmentStep.identification => EstablishmentRegisterStrings.stepOneSubtitle,
      RegisterEstablishmentStep.renspa => EstablishmentRegisterStrings.stepTwoSubtitle,
      RegisterEstablishmentStep.location => EstablishmentRegisterStrings.stepThreeSubtitle,
      RegisterEstablishmentStep.surface => EstablishmentRegisterStrings.stepFourSubtitle,
      RegisterEstablishmentStep.review => EstablishmentRegisterStrings.reviewSubtitle,
    };
  }

  void _goBack(BuildContext context, RegisterEstablishmentStep currentStep) {
    if (currentStep == RegisterEstablishmentStep.identification) {
      _close(context);
      return;
    }

    context.read<RegisterEstablishmentBloc>().add(
      const RegisterEstablishmentEvent.previousStepRequested(),
    );
  }

  void _goNext(BuildContext context, RegisterEstablishmentStep currentStep) {
    if (currentStep == RegisterEstablishmentStep.review) {
      context.read<RegisterEstablishmentBloc>().add(
        const RegisterEstablishmentEvent.submitRequested(),
      );
      return;
    }

    context.read<RegisterEstablishmentBloc>().add(
      const RegisterEstablishmentEvent.nextStepRequested(),
    );
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.home);
  }
}

class _EstablishmentRegisterNavigation extends StatelessWidget {
  const _EstablishmentRegisterNavigation({
    required this.currentStep,
    required this.isSubmitting,
    required this.isStepValid,
    required this.onBack,
    required this.onNext,
  });

  final RegisterEstablishmentStep currentStep;
  final bool isSubmitting;
  final bool isStepValid;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: switch (currentStep) {
        RegisterEstablishmentStep.identification => AppFilledButton(
          label: EstablishmentRegisterStrings.nextButtonLabel,
          icon: const Icon(Icons.arrow_forward),
          onPressed: isStepValid ? onNext : null,
        ),
        RegisterEstablishmentStep.review => AppFilledButton(
          label: isSubmitting
              ? EstablishmentRegisterStrings.savingButtonLabel
              : EstablishmentRegisterStrings.createButtonLabel,
          icon: isSubmitting ? const Icon(Icons.sync) : const Icon(Icons.check),
          onPressed: isSubmitting || !isStepValid ? null : onNext,
        ),
        _ => Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                label: EstablishmentRegisterStrings.backButtonLabel,
                onPressed: onBack,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: AppFilledButton(
                label: currentStep == RegisterEstablishmentStep.surface
                    ? EstablishmentRegisterStrings.surfaceStepNextButtonLabel
                    : EstablishmentRegisterStrings.nextButtonLabel,
                icon: Icon(
                  currentStep == RegisterEstablishmentStep.surface ? Icons.checklist : Icons.arrow_forward,
                ),
                onPressed: isStepValid ? onNext : null,
              ),
            ),
          ],
        ),
      },
    );
  }
}
