import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_parent.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/animal_identification_summary.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/destination_selection_card.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/genealogy_animal_selector.dart';

/// Genealogy and destination form shown in the third registration step.
class RegisterAnimalGenealogyStep extends StatefulWidget {
  /// Creates the genealogy and destination step.
  const RegisterAnimalGenealogyStep({super.key});

  @override
  State<RegisterAnimalGenealogyStep> createState() => _RegisterAnimalGenealogyStepState();
}

class _RegisterAnimalGenealogyStepState extends State<RegisterAnimalGenealogyStep> {
  String _motherSearch = '';
  String _fatherSearch = '';
  String? _lastEstablishmentId;

  List<GenealogyAnimalOption> _matches(List<AnimalParent> parents, AnimalSex sex, String text) {
    final query = text.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    if (query.isEmpty) return const [];
    return parents
        .where(
          (animal) =>
              animal.sex == sex &&
              (animal.visualTag.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(query) ||
                  animal.rfid.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(query)),
        )
        .map(_option)
        .toList(growable: false);
  }

  GenealogyAnimalOption _option(AnimalParent animal) => GenealogyAnimalOption(
    id: animal.id,
    visualTag: animal.visualTag,
    rfid: animal.rfid,
    breed: animal.breed,
  );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RegisterAnimalBloc>().state;
    final draft = state.draft;
    final showErrors = state.showStepValidationErrors;
    if (_lastEstablishmentId != draft.establishmentId) {
      _lastEstablishmentId = draft.establishmentId;
      _motherSearch = '';
      _fatherSearch = '';
    }
    final parents = switch (state.parentsState) {
      Data<List<AnimalParent>>(:final data) => data,
      _ => <AnimalParent>[],
    };
    final motherMatches = _matches(parents, AnimalSex.female, _motherSearch);
    final fatherMatches = _matches(parents, AnimalSex.male, _fatherSearch);

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
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                switch (state.establishmentsState) {
                  Initial() || Loading() => const Center(child: CircularProgressIndicator()),
                  ResultError(:final error) => Text(error.message, style: AppTypography.errorBody),
                  Data(:final data) when data.isEmpty => const Text(
                    AnimalRegisterStrings.noEstablishmentsMessage,
                    style: AppTypography.pageBodyTitle,
                  ),
                  Data(:final data) => AppDropdownFormField<String>(
                    key: ValueKey(draft.establishmentId),
                    title: AnimalRegisterStrings.establishmentSelectorLabel,
                    hintText: AnimalRegisterStrings.establishmentSelectorHint,
                    initialValue: draft.establishmentId,
                    errorText: showErrors && draft.establishmentId == null
                        ? AnimalRegisterStrings.establishmentRequired
                        : null,
                    options: [
                      for (final establishment in data)
                        AppDropdownOption(value: establishment.id, label: establishment.name),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        context.read<RegisterAnimalBloc>().add(RegisterAnimalEvent.establishmentSelected(value));
                      }
                    },
                  ),
                  _ => const SizedBox.shrink(),
                },
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  AnimalRegisterStrings.stepThreeDestinationTitle,
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  AnimalRegisterStrings.stepThreeDestinationDescription,
                  style: AppTypography.pageBodyTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                switch (state.destinationsState) {
                  Initial() when draft.establishmentId == null => const SizedBox.shrink(),
                  Initial() || Loading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ResultError(:final error) => Text(
                    error.message,
                    style: AppTypography.errorBody,
                  ),
                  Data(:final data) when data.isEmpty => const Text(
                    AnimalRegisterStrings.noActiveLotsMessage,
                    style: AppTypography.pageBodyTitle,
                  ),
                  Data(:final data) => Column(
                    children: [
                      for (final destination in data) ...[
                        DestinationSelectionCard(
                          destination: destination,
                          isSelected: draft.destinationId == destination.id,
                          onTap: () {
                            _updateDraft(
                              draft.copyWith(
                                destinationId: draft.destinationId == destination.id ? null : destination.id,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                    ],
                  ),
                  _ => const SizedBox.shrink(),
                },
                if (showErrors && draft.destinationId == null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    AnimalRegisterStrings.destinationRequired,
                    style: AppTypography.formFieldError,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.border),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  AnimalRegisterStrings.stepThreeGenealogyTitle,
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  AnimalRegisterStrings.stepThreeGenealogyDescription,
                  style: AppTypography.pageBodyTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.parentsState case ResultError(:final error)) ...[
                  Text(error.message, style: AppTypography.errorBody),
                  const SizedBox(height: AppSpacing.md),
                ],
                GenealogyAnimalSelector(
                  key: ValueKey('mother-${draft.establishmentId}'),
                  title: AnimalRegisterStrings.stepThreeMotherTitle,
                  searchHint: AnimalRegisterStrings.stepThreeSearchHint,
                  selectedAnimal: draft.mother == null ? null : _option(draft.mother!),
                  options: motherMatches,
                  enabled: draft.establishmentId != null && state.parentsState is Data<List<AnimalParent>>,
                  validationMessage:
                      _motherSearch.trim().isNotEmpty &&
                          state.parentsState is Data<List<AnimalParent>> &&
                          motherMatches.isEmpty
                      ? AnimalRegisterStrings.parentNotFound
                      : null,
                  onSearchChanged: (value) => setState(() => _motherSearch = value),
                  onClear: () {
                    setState(() => _motherSearch = '');
                    _updateDraft(draft.copyWith(mother: null));
                  },
                  onSelected: (animal) {
                    _updateDraft(draft.copyWith(mother: parents.firstWhere((item) => item.id == animal.id)));
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                GenealogyAnimalSelector(
                  key: ValueKey('father-${draft.establishmentId}'),
                  title: AnimalRegisterStrings.stepThreeFatherTitle,
                  searchHint: AnimalRegisterStrings.stepThreeSearchHint,
                  selectedAnimal: draft.father == null ? null : _option(draft.father!),
                  options: fatherMatches,
                  enabled: draft.establishmentId != null && state.parentsState is Data<List<AnimalParent>>,
                  validationMessage:
                      _fatherSearch.trim().isNotEmpty &&
                          state.parentsState is Data<List<AnimalParent>> &&
                          fatherMatches.isEmpty
                      ? AnimalRegisterStrings.parentNotFound
                      : null,
                  onSearchChanged: (value) {
                    setState(() => _fatherSearch = value);
                  },
                  onClear: () {
                    setState(() => _fatherSearch = '');
                    _updateDraft(draft.copyWith(father: null));
                  },
                  onSelected: (animal) {
                    _updateDraft(draft.copyWith(father: parents.firstWhere((item) => item.id == animal.id)));
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
