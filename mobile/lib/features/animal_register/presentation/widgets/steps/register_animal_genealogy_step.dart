import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
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
  static const _mother = GenealogyAnimalOption(
    id: 'mother-003-0421',
    visualTag: AnimalRegisterStrings.stepThreeMockMotherTag,
    name: AnimalRegisterStrings.stepThreeMockMotherName,
    breed: '',
    rfid: AnimalRegisterStrings.stepThreeMockMotherRfid,
    tagColor: AppColors.earTagYellow,
  );

  static const _fatherOptions = [
    GenealogyAnimalOption(
      id: 'father-003-0820',
      visualTag: AnimalRegisterStrings.stepThreeMockFatherOneTag,
      name: AnimalRegisterStrings.stepThreeMockFatherOneName,
      breed: AnimalRegisterStrings.stepThreeMockFatherOneBreed,
      badge: AnimalRegisterStrings.stepThreeBullBadge,
      tagColor: AppColors.earTagBlue,
    ),
    GenealogyAnimalOption(
      id: 'father-003-0612',
      visualTag: AnimalRegisterStrings.stepThreeMockFatherTwoTag,
      name: AnimalRegisterStrings.stepThreeMockFatherTwoName,
      breed: AnimalRegisterStrings.stepThreeMockFatherTwoBreed,
      badge: AnimalRegisterStrings.stepThreeBullBadge,
      tagColor: AppColors.earTagBlue,
    ),
    GenealogyAnimalOption(
      id: 'father-002-0118',
      visualTag: AnimalRegisterStrings.stepThreeMockFatherThreeTag,
      name: AnimalRegisterStrings.stepThreeMockFatherThreeName,
      breed: AnimalRegisterStrings.stepThreeMockFatherThreeBreed,
      badge: AnimalRegisterStrings.stepThreeBullBadge,
      tagColor: AppColors.earTagBlue,
    ),
  ];

  static const _destination = AnimalDestinationOption(
    id: 'destination-la-cumbre',
    name: AnimalRegisterStrings.stepThreeMockDestinationName,
    details: AnimalRegisterStrings.stepThreeMockDestinationDetails,
  );

  String _fatherSearch = '';

  List<GenealogyAnimalOption> get _filteredFatherOptions {
    final query = _fatherSearch.trim().toLowerCase();
    if (query.isEmpty) {
      return _fatherOptions;
    }

    return _fatherOptions.where((animal) {
      final searchableText = '${animal.visualTag} ${animal.name} ${animal.breed}'.toLowerCase();
      return searchableText.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.select(
      (RegisterAnimalBloc bloc) => bloc.state.draft,
    );

    return Column(
      children: [
        AnimalIdentificationSummary(
          rfid: draft.rfid,
          visualTag: _visualTag(draft),
          readingDescription: AnimalRegisterStrings.stepTwoMockReading,
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
                GenealogyAnimalSelector(
                  title: AnimalRegisterStrings.stepThreeMotherTitle,
                  searchHint: AnimalRegisterStrings.stepThreeSearchHint,
                  selectedAnimal: draft.motherId == _mother.id ? _mother : null,
                  options: const [_mother],
                  onClear: () {
                    _updateDraft(draft.copyWith(motherId: null));
                  },
                  onSelected: (animal) {
                    _updateDraft(draft.copyWith(motherId: animal.id));
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                GenealogyAnimalSelector(
                  title: AnimalRegisterStrings.stepThreeFatherTitle,
                  searchHint: AnimalRegisterStrings.stepThreeSearchHint,
                  selectedAnimal: _fatherById(draft.fatherId),
                  options: _filteredFatherOptions,
                  onSearchChanged: (value) {
                    setState(() => _fatherSearch = value);
                  },
                  onClear: () {
                    _updateDraft(draft.copyWith(fatherId: null));
                  },
                  onSelected: (animal) {
                    _updateDraft(draft.copyWith(fatherId: animal.id));
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.border),
                const SizedBox(height: AppSpacing.md),
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
                DestinationSelectionCard(
                  destination: _destination,
                  isSelected: draft.destinationId == _destination.id,
                  onTap: () {
                    _updateDraft(
                      draft.copyWith(
                        destinationId: draft.destinationId == _destination.id ? null : _destination.id,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  GenealogyAnimalOption? _fatherById(String? fatherId) {
    for (final father in _fatherOptions) {
      if (father.id == fatherId) {
        return father;
      }
    }
    return null;
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
