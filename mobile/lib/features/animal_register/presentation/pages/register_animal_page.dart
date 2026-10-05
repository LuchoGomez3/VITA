import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_basic_data_step.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_genealogy_step.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_identification_step.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/steps/register_animal_review_step.dart';
import 'package:go_router/go_router.dart';

/// Factory usada por composition root/router para construir el BLoC.
typedef RegisterAnimalBlocFactory =
    RegisterAnimalBloc Function({
      RegisterAnimalStep initialStep,
      String initialRfid,
      String? initialEstablishmentId,
    });

/// Hosts the complete animal registration flow.
class RegisterAnimalPage extends StatelessWidget {
  /// Creates the animal registration flow.
  const RegisterAnimalPage({
    required this.createBloc,
    this.initialStep = RegisterAnimalStep.identification,
    this.initialRfid = '',
    this.initialEstablishmentId,
    super.key,
  });

  /// Crea el BLoC con dependencias ya resueltas fuera de presentation.
  final RegisterAnimalBlocFactory createBloc;

  /// Step displayed when the flow is opened.
  final RegisterAnimalStep initialStep;

  /// RFID opcional recibido desde una lectura de identificacion.
  final String initialRfid;

  /// Establecimiento opcional recibido desde el flujo que inicia el alta.
  final String? initialEstablishmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(
        initialStep: initialStep,
        initialRfid: initialRfid,
        initialEstablishmentId: initialEstablishmentId,
      ),
      child: const _RegisterAnimalView(),
    );
  }
}

class _RegisterAnimalView extends StatelessWidget {
  const _RegisterAnimalView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterAnimalBloc, RegisterAnimalState>(
      listenWhen: (previous, current) => previous.submitResult != current.submitResult,
      listener: (context, state) {
        switch (state.submitResult) {
          case Data<RegisteredAnimal>(:final data):
            context.push(
              AppRoutes.animalRegisterSuccess,
              extra: data,
            );
          case ResultError<RegisteredAnimal>(:final error):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(error.message)),
              );
          default:
            break;
        }
      },
      child: BlocBuilder<RegisterAnimalBloc, RegisterAnimalState>(
        buildWhen: (previous, current) {
          return previous.currentStep != current.currentStep || previous.submitResult != current.submitResult;
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _close(context),
              ),
              actions: const [SizedBox(width: 48)],
              title: const Text(
                AnimalRegisterStrings.pageTitle,
                style: AppTypography.appBarTitle,
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppColors.border),
              ),
            ),
            body: Column(
              children: [
                StepProgressBar(
                  currentStep: state.currentStep.index + 1,
                  totalSteps: RegisterAnimalStep.values.length,
                  stepTitle: _stepTitle(state.currentStep),
                ),
                Expanded(
                  child: IndexedStack(
                    index: state.currentStep.index,
                    children: [
                      RegisterAnimalIdentificationStep(
                        onBluetoothRequested: () => _requestBluetoothReading(context),
                      ),
                      const RegisterAnimalBasicDataStep(),
                      const RegisterAnimalGenealogyStep(),
                      const RegisterAnimalReviewStep(),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _RegisterAnimalNavigation(
              currentStep: state.currentStep,
              isSubmitting: state.submitResult is Loading<RegisteredAnimal>,
              onBack: () => _goBack(context, state.currentStep),
              onNext: () => _goNext(context, state.currentStep),
            ),
          );
        },
      ),
    );
  }

  static String _stepTitle(RegisterAnimalStep step) {
    return switch (step) {
      RegisterAnimalStep.identification => AnimalRegisterStrings.progressIdentificationTitle,
      RegisterAnimalStep.basicData => AnimalRegisterStrings.progressBasicDataTitle,
      RegisterAnimalStep.genealogy => AnimalRegisterStrings.progressDestinationTitle,
      RegisterAnimalStep.review => AnimalRegisterStrings.progressReviewTitle,
    };
  }

  Future<void> _requestBluetoothReading(BuildContext context) async {
    final rfid = await context.push<String>(AppRoutes.rfidCapture);
    if (!context.mounted || rfid == null) return;
    context.read<RegisterAnimalBloc>().add(RegisterAnimalEvent.rfidCaptured(rfid));
  }

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
      context.read<RegisterAnimalBloc>().add(
        const RegisterAnimalEvent.submitRequested(),
      );
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
    required this.isSubmitting,
    required this.onBack,
    required this.onNext,
  });

  final RegisterAnimalStep currentStep;
  final bool isSubmitting;
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
                    label: isSubmitting
                        ? AnimalRegisterStrings.stepFourSaveButton
                        : currentStep == RegisterAnimalStep.review
                        ? AnimalRegisterStrings.stepFourSaveButton
                        : AnimalRegisterStrings.stepTwoNextButton,
                    icon: isSubmitting
                        ? const Icon(Icons.sync)
                        : Icon(
                            currentStep == RegisterAnimalStep.review ? Icons.check : Icons.arrow_forward,
                          ),
                    onPressed: isSubmitting ? null : onNext,
                  ),
                ),
              ],
            ),
    );
  }
}
