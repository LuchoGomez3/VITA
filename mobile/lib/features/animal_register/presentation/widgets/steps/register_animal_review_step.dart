import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_context.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_review_section.dart';

/// Registration summary shown before saving the animal.
class RegisterAnimalReviewStep extends StatelessWidget {
  /// Creates the registration review step.
  const RegisterAnimalReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RegisterAnimalBloc>().state;
    final draft = state.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AnimalRegisterStrings.stepFourTitle,
            style: AppTypography.pageTitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            AnimalRegisterStrings.stepFourDescription,
            style: AppTypography.pageBodyTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          RegisterAnimalReviewSection(
            order: 1,
            title: AnimalRegisterStrings.stepFourIdentificationTitle,
            onEdit: () => _edit(context, RegisterAnimalStep.identification),
            leading: _ReviewEarTag(
              visualTag: _visualTag(draft),
              color: AnimalRegisterStrings.earTagColorOptions[draft.earTagColorIndex].color,
            ),
            rows: [
              RegisterAnimalReviewRow(
                label: '',
                value: draft.rfid,
              ),
              RegisterAnimalReviewRow(
                label: '',
                value: _visualTag(draft),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RegisterAnimalReviewSection(
            order: 2,
            title: AnimalRegisterStrings.stepFourBasicDataTitle,
            onEdit: () => _edit(context, RegisterAnimalStep.basicData),
            rows: [
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourBreedLabel,
                value: draft.breed,
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourSexLabel,
                value: draft.sex,
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourBirthDateLabel,
                value: _date(draft.birthDate),
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourCategoryLabel,
                value: draft.category,
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourBirthWeightLabel,
                value: draft.birthWeight,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RegisterAnimalReviewSection(
            order: 3,
            title: AnimalRegisterStrings.stepFourGenealogyTitle,
            onEdit: () => _edit(context, RegisterAnimalStep.genealogy),
            rows: [
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourMotherLabel,
                value: _mother(draft.motherId),
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourFatherLabel,
                value: _father(draft.fatherId),
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourDestinationLabel,
                value: _destination(
                  draft.destinationId,
                  state.destinations,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _edit(BuildContext context, RegisterAnimalStep step) {
    context.read<RegisterAnimalBloc>().add(
      RegisterAnimalEvent.stepRequested(step),
    );
  }

  String _visualTag(RegisterAnimalDraft draft) {
    return '${draft.visualTagSeries} ${draft.visualTagNumber}'.trim();
  }

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _mother(String? id) {
    // TODO(agusf): resolver el nombre desde los animales cargados en el BLoC
    // cuando la genealogia deje de utilizar opciones estaticas.
    return id == 'mother-003-0421'
        ? AnimalRegisterStrings.stepFourMotherValue
        : AnimalRegisterStrings.stepFourNoDataValue;
  }

  String _father(String? id) {
    // TODO(agusf): resolver el nombre desde los animales cargados en el BLoC
    // cuando la genealogia deje de utilizar opciones estaticas.
    return switch (id) {
      'father-003-0820' => AnimalRegisterStrings.stepThreeMockFatherOneName,
      'father-003-0612' => AnimalRegisterStrings.stepThreeMockFatherTwoName,
      'father-002-0118' => AnimalRegisterStrings.stepThreeMockFatherThreeName,
      _ => AnimalRegisterStrings.stepFourNoDataValue,
    };
  }

  String _destination(
    String? id,
    List<AnimalRegistrationDestination> destinations,
  ) {
    for (final destination in destinations) {
      if (destination.id == id) {
        return '${destination.name} · ${destination.details}';
      }
    }
    return AnimalRegisterStrings.stepFourNoDataValue;
  }
}

class _ReviewEarTag extends StatelessWidget {
  const _ReviewEarTag({
    required this.visualTag,
    required this.color,
  });

  final String visualTag;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        visualTag.replaceFirst(' ', '\n'),
        style: AppTypography.smallEmphasis.copyWith(
          color: AppColors.textPrimary,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
