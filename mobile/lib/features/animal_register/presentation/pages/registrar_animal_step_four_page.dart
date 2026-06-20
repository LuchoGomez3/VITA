import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_app_bar_title.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_progress_indicator.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_review_section.dart';
import 'package:go_router/go_router.dart';

/// Cuarto paso del flujo de alta de animal: revision final.
class RegistrarAnimalStepFourPage extends StatelessWidget {
  /// Crea la pantalla de revision previa al guardado.
  const RegistrarAnimalStepFourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: const [SizedBox(width: 48)],
        title: const RegisterAnimalAppBarTitle(
          stepSubtitle: AnimalRegisterStrings.stepFourSubtitle,
        ),
      ),
      body: const Column(
        children: [
          RegisterAnimalProgressIndicator(currentStep: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AnimalRegisterStrings.stepFourTitle,
                    style: AppTypography.pageTitle,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    AnimalRegisterStrings.stepFourDescription,
                    style: AppTypography.pageBodyTitle,
                  ),
                  SizedBox(height: AppSpacing.md),
                  RegisterAnimalReviewSection(
                    order: 1,
                    title: AnimalRegisterStrings.stepFourIdentificationTitle,
                    leading: _ReviewEarTag(),
                    rows: [
                      RegisterAnimalReviewRow(
                        label: '',
                        value: AnimalRegisterStrings.stepFourIdentificationRfid,
                      ),
                      RegisterAnimalReviewRow(
                        label: '',
                        value: AnimalRegisterStrings.stepFourIdentificationTag,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  RegisterAnimalReviewSection(
                    order: 2,
                    title: AnimalRegisterStrings.stepFourBasicDataTitle,
                    rows: [
                      RegisterAnimalReviewRow(
                        label: AnimalRegisterStrings.stepFourBreedLabel,
                        value: AnimalRegisterStrings.stepFourBreedValue,
                      ),
                      RegisterAnimalReviewRow(
                        label: AnimalRegisterStrings.stepFourSexLabel,
                        value: AnimalRegisterStrings.stepFourSexValue,
                      ),
                      RegisterAnimalReviewRow(
                        label: AnimalRegisterStrings.stepFourBirthDateLabel,
                        value: AnimalRegisterStrings.stepFourBirthDateValue,
                      ),
                      RegisterAnimalReviewRow(
                        label: AnimalRegisterStrings.stepFourCategoryLabel,
                        value: AnimalRegisterStrings.stepFourCategoryValue,
                      ),
                      RegisterAnimalReviewRow(
                        label: AnimalRegisterStrings.stepFourBirthWeightLabel,
                        value: AnimalRegisterStrings.stepFourBirthWeightValue,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  RegisterAnimalReviewSection(
                    order: 3,
                    title: AnimalRegisterStrings.stepFourGenealogyTitle,
                    rows: [
                      RegisterAnimalReviewRow(
                        label: AnimalRegisterStrings.stepFourMotherLabel,
                        value: AnimalRegisterStrings.stepFourMotherValue,
                      ),
                      RegisterAnimalReviewRow(
                        label: AnimalRegisterStrings.stepFourFatherLabel,
                        value: AnimalRegisterStrings.stepFourFatherValue,
                      ),
                      RegisterAnimalReviewRow(
                        label: AnimalRegisterStrings.stepFourDestinationLabel,
                        value: AnimalRegisterStrings.stepFourDestinationValue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                label: AnimalRegisterStrings.stepFourBackButton,
                onPressed: () => _handleBack(context),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: AppFilledButton(
                label: AnimalRegisterStrings.stepFourSaveButton,
                icon: const Icon(Icons.check),
                onPressed: () => context.push(AppRoutes.animalRegisterSuccess),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.animalRegisterStep3);
  }
}

class _ReviewEarTag extends StatelessWidget {
  const _ReviewEarTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.earTagYellow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        AnimalRegisterStrings.stepFourIdentificationVisualTag.replaceFirst(
          ' ',
          '\n',
        ),
        style: AppTypography.smallEmphasis.copyWith(
          color: AppColors.textPrimary,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
