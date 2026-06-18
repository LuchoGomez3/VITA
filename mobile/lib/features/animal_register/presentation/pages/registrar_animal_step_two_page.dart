import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/animal_identification_summary.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_app_bar_title.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_progress_indicator.dart';
import 'package:go_router/go_router.dart';

enum _BirthDatePreset {
  today,
  oneMonthAgo,
  sixMonthsAgo,
  oneYearAgo,
}

/// Segundo paso del flujo de alta de animal: datos básicos.
class RegistrarAnimalStepTwoPage extends StatefulWidget {
  /// Crea la pantalla que recopila los datos basicos del animal.
  const RegistrarAnimalStepTwoPage({super.key});

  @override
  State<RegistrarAnimalStepTwoPage> createState() => _RegistrarAnimalStepTwoPageState();
}

class _RegistrarAnimalStepTwoPageState extends State<RegistrarAnimalStepTwoPage> {
  final _birthWeightController = TextEditingController();

  String _selectedBreed = AnimalRegisterStrings.stepTwoBreedOptions.first;
  String _selectedSex = AnimalRegisterStrings.stepTwoFemale;
  DateTime _selectedBirthDate = DateTime(2025, 3, 14);
  _BirthDatePreset? _selectedDatePreset;
  String _selectedCategory = AnimalRegisterStrings.stepTwoCategories.first;

  @override
  void dispose() {
    _birthWeightController.dispose();
    super.dispose();
  }

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
          stepSubtitle: AnimalRegisterStrings.stepTwoSubtitle,
        ),
      ),
      body: Column(
        children: [
          const RegisterAnimalProgressIndicator(currentStep: 2),
          const AnimalIdentificationSummary(
            rfid: AnimalRegisterStrings.stepTwoMockRfid,
            visualTag: AnimalRegisterStrings.stepTwoMockVisualTag,
            readingDescription: AnimalRegisterStrings.stepTwoMockReading,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AnimalRegisterStrings.stepTwoSectionTitle,
                    style: AppTypography.pageTitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppDropdownFormField<String>(
                    title: AnimalRegisterStrings.stepTwoBreedTitle,
                    hintText: AnimalRegisterStrings.stepTwoBreedHint,
                    initialValue: _selectedBreed,
                    options: AnimalRegisterStrings.stepTwoBreedOptions
                        .map(
                          (breed) => AppDropdownOption(
                            value: breed,
                            label: breed,
                          ),
                        )
                        .toList(),
                    onChanged: (breed) {
                      if (breed == null) {
                        return;
                      }

                      setState(() => _selectedBreed = breed);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppSegmentedFormField<String>(
                    title: AnimalRegisterStrings.stepTwoSexTitle,
                    value: _selectedSex,
                    options: const [
                      AppSegmentedOption(
                        value: AnimalRegisterStrings.stepTwoFemale,
                        label: AnimalRegisterStrings.stepTwoFemale,
                      ),
                      AppSegmentedOption(
                        value: AnimalRegisterStrings.stepTwoMale,
                        label: AnimalRegisterStrings.stepTwoMale,
                      ),
                    ],
                    onChanged: (sex) {
                      setState(() => _selectedSex = sex);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppDateFormField(
                    title: AnimalRegisterStrings.stepTwoBirthDateTitle,
                    hintText: AnimalRegisterStrings.stepTwoBirthDateHint,
                    value: _selectedBirthDate,
                    onChanged: (date) {
                      setState(() {
                        _selectedBirthDate = date;
                        _selectedDatePreset = null;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppChoiceSelector<_BirthDatePreset>(
                    value: _selectedDatePreset,
                    selectedColor: AppColors.backgroundSecondary,
                    selectedTextColor: AppColors.primary,
                    unSelectedColor: AppColors.backgroundTertiary,
                    options: const [
                      AppChoiceOption(
                        value: _BirthDatePreset.today,
                        label: AnimalRegisterStrings.stepTwoToday,
                      ),
                      AppChoiceOption(
                        value: _BirthDatePreset.oneMonthAgo,
                        label: AnimalRegisterStrings.stepTwoOneMonthAgo,
                      ),
                      AppChoiceOption(
                        value: _BirthDatePreset.sixMonthsAgo,
                        label: AnimalRegisterStrings.stepTwoSixMonthsAgo,
                      ),
                      AppChoiceOption(
                        value: _BirthDatePreset.oneYearAgo,
                        label: AnimalRegisterStrings.stepTwoOneYearAgo,
                      ),
                    ],
                    onChanged: _applyBirthDatePreset,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppChoiceSelector<String>(
                    title: AnimalRegisterStrings.stepTwoCategoryTitle,
                    value: _selectedCategory,
                    options: AnimalRegisterStrings.stepTwoCategories
                        .map(
                          (category) => AppChoiceOption(
                            value: category,
                            label: category,
                          ),
                        )
                        .toList(),
                    onChanged: (category) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    AnimalRegisterStrings.stepTwoCategorySuggestion,
                    style: AppTypography.pageBodyTitle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextFormField(
                    controller: _birthWeightController,
                    title: AnimalRegisterStrings.stepTwoBirthWeightTitle,
                    hintText: AnimalRegisterStrings.stepTwoBirthWeightHint,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*[,.]?\d{0,2}'),
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
                label: AnimalRegisterStrings.stepTwoBackButton,
                onPressed: _handleBack,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: AppFilledButton(
                label: AnimalRegisterStrings.stepTwoNextButton,
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => context.push(
                  AppRoutes.animalRegisterStep3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.animalRegisterStep1);
  }

  void _applyBirthDatePreset(_BirthDatePreset preset) {
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedDate = switch (preset) {
      _BirthDatePreset.today => today,
      _BirthDatePreset.oneMonthAgo => _subtractMonths(today, 1),
      _BirthDatePreset.sixMonthsAgo => _subtractMonths(today, 6),
      _BirthDatePreset.oneYearAgo => DateTime(
        today.year - 1,
        today.month,
        today.day,
      ),
    };

    setState(() {
      _selectedDatePreset = preset;
      _selectedBirthDate = selectedDate;
    });
  }

  DateTime _subtractMonths(DateTime date, int months) {
    final targetMonth = date.month - months;
    final targetYear = date.year + ((targetMonth - 1) ~/ 12);
    final normalizedMonth = ((targetMonth - 1) % 12) + 1;
    final lastDay = DateUtils.getDaysInMonth(targetYear, normalizedMonth);
    final normalizedDay = date.day > lastDay ? lastDay : date.day;

    return DateTime(
      targetYear,
      normalizedMonth,
      normalizedDay,
    );
  }
}
