import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/animal_identification_summary.dart';

enum _BirthDatePreset {
  today,
  oneMonthAgo,
  sixMonthsAgo,
  oneYearAgo,
}

/// Basic animal data form shown in the second registration step.
class RegisterAnimalBasicDataStep extends StatefulWidget {
  /// Creates the basic animal data step.
  const RegisterAnimalBasicDataStep({super.key});

  @override
  State<RegisterAnimalBasicDataStep> createState() => _RegisterAnimalBasicDataStepState();
}

class _RegisterAnimalBasicDataStepState extends State<RegisterAnimalBasicDataStep> {
  final _birthWeightController = TextEditingController();

  _BirthDatePreset? _selectedDatePreset;

  @override
  void initState() {
    super.initState();
    _birthWeightController.text = context.read<RegisterAnimalBloc>().state.draft.birthWeight;
  }

  @override
  void dispose() {
    _birthWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.select(
      (RegisterAnimalBloc bloc) => bloc.state.draft,
    );

    return Column(
      children: [
        // TODO(agusf): mostrar metodo y fecha reales recibidos del flujo RFID,
        // OCR o carga manual cuando identificacion entregue esos metadatos.
        AnimalIdentificationSummary(
          rfid: draft.rfid,
          visualTag: _visualTag(draft),
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
                  initialValue: draft.breed,
                  // TODO(agusf): reemplazar por el catalogo offline de razas
                  // cuando backend defina y sincronice esa fuente.
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
                  value: draft.sex,
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
                AppChoiceSelector<String>(
                  title: AnimalRegisterStrings.stepTwoCategoryTitle,
                  value: draft.category,
                  // TODO(agusf): consumir categorias desde el BLoC usando el
                  // catalogo Brick, con UUID real como valor seleccionado.
                  options: AnimalRegisterStrings.stepTwoCategories
                      .map(
                        (category) => AppChoiceOption(
                          value: category,
                          label: category,
                        ),
                      )
                      .toList(),
                  onChanged: (category) {
                    _updateDraft(draft.copyWith(category: category));
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*[,.]?\d{0,2}'),
                    ),
                  ],
                  onChanged: (value) {
                    _updateDraft(draft.copyWith(birthWeight: value));
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

  void _updateDraft(RegisterAnimalDraft draft) {
    context.read<RegisterAnimalBloc>().add(
      RegisterAnimalEvent.draftChanged(draft),
    );
  }
}
