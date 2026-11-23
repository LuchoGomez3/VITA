import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/animal_identification_summary.dart';

enum _BirthDatePreset {
  today,
  oneMonthAgo,
  sixMonthsAgo,
  oneYearAgo,
}

/// Peso confirmado por alguno de los métodos ofrecidos durante el alta.
typedef CapturedInitialWeight = ({double weightKg, AnimalWeighingMethod method});

/// Pide un peso y devuelve `null` si el usuario sale sin confirmar.
typedef CaptureInitialWeight = Future<CapturedInitialWeight?> Function(BuildContext context);

/// Basic animal data form shown in the second registration step.
class RegisterAnimalBasicDataStep extends StatefulWidget {
  /// Creates the basic animal data step.
  const RegisterAnimalBasicDataStep({required this.captureInitialWeight, super.key});

  /// Abre el selector de métodos y recibe el peso confirmado.
  final CaptureInitialWeight captureInitialWeight;

  @override
  State<RegisterAnimalBasicDataStep> createState() => _RegisterAnimalBasicDataStepState();
}

class _RegisterAnimalBasicDataStepState extends State<RegisterAnimalBasicDataStep> {
  final _birthWeightController = TextEditingController();

  _BirthDatePreset? _selectedDatePreset;
  bool _capturingWeight = false;

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegisterAnimalBloc>().state.draft;
    _birthWeightController.text = draft.birthWeight;
  }

  @override
  void dispose() {
    _birthWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RegisterAnimalBloc>().state;
    final draft = state.draft;
    final showErrors = state.showStepValidationErrors;
    final selectableCategories = state.selectableCategories;

    return Column(
      children: [
        AnimalIdentificationSummary(
          rfid: draft.rfid,
          visualTag: _visualTag(draft),
          readingDescription: AnimalRegisterStrings.identificationSummary,
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
                  initialValue: draft.breed.isEmpty ? null : draft.breed,
                  errorText: showErrors && draft.breed.trim().isEmpty ? AnimalRegisterStrings.breedRequired : null,
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
                    _updateDraft(draft.copyWith(breed: breed));
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                AppSegmentedFormField<String>(
                  title: AnimalRegisterStrings.stepTwoSexTitle,
                  value: draft.sex.isEmpty ? null : draft.sex,
                  errorText: showErrors && draft.sex.isEmpty ? AnimalRegisterStrings.sexRequired : null,
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
                    _updateDraft(draft.copyWith(sex: sex));
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppDateFormField(
                  title: AnimalRegisterStrings.stepTwoBirthDateTitle,
                  hintText: AnimalRegisterStrings.stepTwoBirthDateHint,
                  value: draft.birthDate,
                  errorText: showErrors && draft.birthDate == null ? AnimalRegisterStrings.birthDateRequired : null,
                  onChanged: (date) {
                    setState(() {
                      _selectedDatePreset = null;
                    });
                    _updateDraft(draft.copyWith(birthDate: date));
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
                switch (state.categoriesState) {
                  Initial() || Loading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ResultError(:final error) => Text(
                    error.message,
                    style: AppTypography.errorBody,
                  ),
                  Data(:final data) when data.isEmpty => const Text(
                    AnimalRegisterStrings.noCategoriesMessage,
                    style: AppTypography.pageBodyTitle,
                  ),
                  Data() when draft.selectedSex == null => const Text(
                    AnimalRegisterStrings.categorySelectSexHint,
                    style: AppTypography.pageBodyTitle,
                  ),
                  Data() when selectableCategories.isEmpty => const Text(
                    AnimalRegisterStrings.noCategoriesForSexMessage,
                    style: AppTypography.pageBodyTitle,
                  ),
                  Data() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppChoiceSelector<String>(
                        title: AnimalRegisterStrings.stepTwoCategoryTitle,
                        value: draft.categoryId,
                        options: [
                          for (final category in selectableCategories)
                            AppChoiceOption(
                              value: category.id,
                              label: category.name,
                            ),
                        ],
                        onChanged: (categoryId) {
                          final category = selectableCategories.firstWhere(
                            (item) => item.id == categoryId,
                          );
                          _updateDraft(
                            draft.copyWith(
                              categoryId: category.id,
                              categoryName: category.name,
                            ),
                          );
                        },
                      ),
                      if (showErrors && draft.categoryId == null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          AnimalRegisterStrings.categoryRequired,
                          style: AppTypography.formFieldError,
                        ),
                      ],
                    ],
                  ),
                  _ => const SizedBox.shrink(),
                },
                const SizedBox(height: AppSpacing.md),
                AppTextFormField(
                  controller: _birthWeightController,
                  title: AnimalRegisterStrings.weightLabel,
                  hintText: AnimalRegisterStrings.stepTwoBirthWeightHint,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    tooltip: AnimalRegisterStrings.captureWeightTooltip,
                    onPressed: _captureWeight,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*[,.]?\d{0,2}'),
                    ),
                  ],
                  validation: showErrors && !_hasValidWeight(draft.birthWeight)
                      ? AppFieldValidation.invalid
                      : AppFieldValidation.neutral,
                  validationMessage: showErrors && !_hasValidWeight(draft.birthWeight)
                      ? AnimalRegisterStrings.invalidBirthWeight
                      : null,
                  onChanged: (value) {
                    _updateDraft(draft.copyWith(birthWeight: value, weighingMethod: AnimalWeighingMethod.manual));
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _captureWeight() async {
    if (_capturingWeight) return;
    _capturingWeight = true;
    FocusScope.of(context).unfocus();
    try {
      final captured = await widget.captureInitialWeight(context);
      if (!mounted || captured == null) return;
      final draft = context.read<RegisterAnimalBloc>().state.draft;
      final weight = captured.weightKg.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '').replaceAll('.', ',');
      _birthWeightController.value = TextEditingValue(
        text: weight,
        selection: TextSelection.collapsed(offset: weight.length),
      );
      _updateDraft(draft.copyWith(birthWeight: weight, weighingMethod: captured.method));
    } finally {
      _capturingWeight = false;
    }
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
    });
    final draft = context.read<RegisterAnimalBloc>().state.draft;
    _updateDraft(draft.copyWith(birthDate: selectedDate));
  }

  DateTime _subtractMonths(DateTime date, int months) {
    final targetMonth = date.month - months;
    final targetYear = date.year + ((targetMonth - 1) ~/ 12);
    final normalizedMonth = ((targetMonth - 1) % 12) + 1;
    final lastDay = DateUtils.getDaysInMonth(targetYear, normalizedMonth);
    final normalizedDay = date.day > lastDay ? lastDay : date.day;

    return DateTime(targetYear, normalizedMonth, normalizedDay);
  }

  String _visualTag(RegisterAnimalDraft draft) {
    return '${draft.visualTagSeries} ${draft.visualTagNumber}'.trim();
  }

  bool _hasValidWeight(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    return parsed != null && parsed > 0;
  }

  void _updateDraft(RegisterAnimalDraft draft) {
    context.read<RegisterAnimalBloc>().add(
      RegisterAnimalEvent.draftChanged(draft),
    );
  }
}
