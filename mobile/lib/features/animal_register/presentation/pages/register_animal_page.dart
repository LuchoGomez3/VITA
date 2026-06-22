import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_app_bar_title.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_progress_indicator.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_basic_data_step.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_genealogy_step.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_identification_step.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_review_step.dart';
import 'package:go_router/go_router.dart';

/// Hosts the complete animal registration flow.
class RegisterAnimalPage extends StatelessWidget {
  /// Creates the animal registration flow.
  const RegisterAnimalPage({
    this.initialStep = RegisterAnimalStep.identification,
    super.key,
  });

  /// Step displayed when the flow is opened.
  final RegisterAnimalStep initialStep;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterAnimalBloc(initialStep: initialStep),
      child: const _RegisterAnimalView(),
    );
  }
}

class _RegisterAnimalView extends StatelessWidget {
  const _RegisterAnimalView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterAnimalBloc, RegisterAnimalState>(
      buildWhen: (previous, current) => previous.currentStep != current.currentStep,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _close(context),
            ),
            actions: const [SizedBox(width: 48)],
            title: RegisterAnimalAppBarTitle(
              stepSubtitle: _subtitleFor(state.currentStep),
            ),
          ),
          body: Column(
            children: [
              RegisterAnimalProgressIndicator(
                currentStep: state.currentStep.index + 1,
              ),
              Expanded(
                child: IndexedStack(
                  index: state.currentStep.index,
                  children: const [
                    RegisterAnimalIdentificationStep(
                      onBluetoothRequested: _requestBluetoothReading,
                    ),
                    RegisterAnimalBasicDataStep(),
                    RegisterAnimalGenealogyStep(),
                    RegisterAnimalReviewStep(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _RegisterAnimalNavigation(
            currentStep: state.currentStep,
            onBack: () => _goBack(context, state.currentStep),
            onNext: () => _goNext(context, state.currentStep),
          ),
        );
      },
    );
  }

  static String _subtitleFor(RegisterAnimalStep step) {
    return switch (step) {
      RegisterAnimalStep.identification => AnimalRegisterStrings.pageStepSubtitle,
      RegisterAnimalStep.basicData => AnimalRegisterStrings.stepTwoSubtitle,
      RegisterAnimalStep.genealogy => AnimalRegisterStrings.stepThreeSubtitle,
      RegisterAnimalStep.review => AnimalRegisterStrings.stepFourSubtitle,
    };
  }

  static void _requestBluetoothReading() {}

  void _goBack(BuildContext context, RegisterAnimalStep currentStep) {
    if (currentStep == RegisterAnimalStep.identification) {
      _close(context);
      return;
    }

    context.read<RegisterAnimalBloc>().add(
      const RegisterAnimalEvent.previousStepRequested(),
    );
  }

  void _goNext(BuildContext context, RegisterAnimalStep currentStep) {
    if (currentStep == RegisterAnimalStep.review) {
      context.push(AppRoutes.animalRegisterSuccess);
      return;
    }

    context.read<RegisterAnimalBloc>().add(
      const RegisterAnimalEvent.nextStepRequested(),
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

class _RegisterAnimalNavigation extends StatelessWidget {
  const _RegisterAnimalNavigation({
    required this.currentStep,
    required this.onBack,
    required this.onNext,
  });

  final RegisterAnimalStep currentStep;
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
      child: currentStep == RegisterAnimalStep.identification
          ? AppFilledButton(
              label: AnimalRegisterStrings.nextButtonLabel,
              icon: const Icon(Icons.arrow_forward),
              onPressed: onNext,
            )
          : Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    label: AnimalRegisterStrings.stepTwoBackButton,
                    onPressed: onBack,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: AppFilledButton(
                    label: currentStep == RegisterAnimalStep.review
                        ? AnimalRegisterStrings.stepFourSaveButton
                        : AnimalRegisterStrings.stepTwoNextButton,
                    icon: Icon(
                      currentStep == RegisterAnimalStep.review ? Icons.check : Icons.arrow_forward,
                    ),
                    onPressed: onNext,
                  ),
                ),
              ],
            ),
    );
  }
}
