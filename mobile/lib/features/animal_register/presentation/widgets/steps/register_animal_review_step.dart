import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_parent.dart';
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
    final birthDate = draft.birthDate;

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
            rows: [
              RegisterAnimalReviewRow(
                label: '',
                value: draft.rfid,
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
                value: _requiredValue(draft.breed),
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourSexLabel,
                value: _requiredValue(draft.sex),
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourBirthDateLabel,
                value: birthDate == null
                    ? AnimalRegisterStrings.stepFourNoDataValue
                    : DateDisplayFormatter.shortDate(birthDate),
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourCategoryLabel,
                value: draft.categoryName ?? AnimalRegisterStrings.stepFourNoDataValue,
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
                label: AnimalRegisterStrings.stepFourEstablishmentLabel,
                value: draft.establishmentName ?? AnimalRegisterStrings.stepFourNoDataValue,
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourMotherLabel,
                value: _parent(draft.mother),
              ),
              RegisterAnimalReviewRow(
                label: AnimalRegisterStrings.stepFourFatherLabel,
                value: _parent(draft.father),
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

  String _parent(AnimalParent? parent) =>
      parent == null ? AnimalRegisterStrings.stepFourNoDataValue : '${parent.visualTag} · ${parent.breed}';

  String _requiredValue(String value) => value.trim().isEmpty ? AnimalRegisterStrings.stepFourNoDataValue : value;

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
