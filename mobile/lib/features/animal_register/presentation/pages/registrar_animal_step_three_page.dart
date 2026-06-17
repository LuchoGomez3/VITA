import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/animal_identification_summary.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/destination_selection_card.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/genealogy_animal_selector.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_app_bar_title.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/register_animal_progress_indicator.dart';
import 'package:go_router/go_router.dart';

/// Tercer paso del flujo de alta de animal: genealogia y destino.
class RegistrarAnimalStepThreePage extends StatefulWidget {
  /// Crea la pantalla de seleccion de progenitores y destino.
  const RegistrarAnimalStepThreePage({super.key});

  @override
  State<RegistrarAnimalStepThreePage> createState() => _RegistrarAnimalStepThreePageState();
}

class _RegistrarAnimalStepThreePageState extends State<RegistrarAnimalStepThreePage> {
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

  GenealogyAnimalOption? _selectedMother = _mother;
  GenealogyAnimalOption? _selectedFather;
  AnimalDestinationOption? _selectedDestination = _destination;
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: const [SizedBox(width: 48)],
        title: const RegisterAnimalAppBarTitle(
          stepSubtitle: AnimalRegisterStrings.stepThreeSubtitle,
        ),
      ),
      body: Column(
        children: [
          const RegisterAnimalProgressIndicator(currentStep: 3),
          const AnimalIdentificationSummary(
            rfid: AnimalRegisterStrings.stepTwoMockRfid,
            visualTag: AnimalRegisterStrings.stepTwoMockVisualTag,
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
                    selectedAnimal: _selectedMother,
                    options: const [_mother],
                    onClear: () => setState(() => _selectedMother = null),
                    onSelected: (animal) {
                      setState(() => _selectedMother = animal);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GenealogyAnimalSelector(
                    title: AnimalRegisterStrings.stepThreeFatherTitle,
                    searchHint: AnimalRegisterStrings.stepThreeSearchHint,
                    selectedAnimal: _selectedFather,
                    options: _filteredFatherOptions,
                    onSearchChanged: (value) {
                      setState(() => _fatherSearch = value);
                    },
                    onClear: () => setState(() => _selectedFather = null),
                    onSelected: (animal) {
                      setState(() => _selectedFather = animal);
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
                    isSelected: _selectedDestination == _destination,
                    onTap: () {
                      setState(() {
                        _selectedDestination = _selectedDestination == _destination ? null : _destination;
                      });
                    },
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
                label: AnimalRegisterStrings.stepThreeBackButton,
                onPressed: _handleBack,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: AppFilledButton(
                label: AnimalRegisterStrings.stepThreeNextButton,
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => context.push(AppRoutes.animalRegisterStep4),
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

    context.go(AppRoutes.animalRegisterStep2);
  }
}
