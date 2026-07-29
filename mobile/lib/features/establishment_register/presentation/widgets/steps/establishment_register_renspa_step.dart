import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/establishment_info_callout.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/renspa_breakdown_panel.dart';

/// Paso 2 · CUIT del titular y número de RENSPA del establecimiento.
class EstablishmentRegisterRenspaStep extends StatefulWidget {
  /// Crea el paso de RENSPA y titular del establecimiento.
  const EstablishmentRegisterRenspaStep({super.key});

  @override
  State<EstablishmentRegisterRenspaStep> createState() => _EstablishmentRegisterRenspaStepState();
}

class _EstablishmentRegisterRenspaStepState extends State<EstablishmentRegisterRenspaStep> {
  final _cuitController = TextEditingController();
  final _renspaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegisterEstablishmentBloc>().state.draft;
    _cuitController.text = draft.cuitTitular;
    _renspaController.text = draft.nroRenspa;
  }

  @override
  void dispose() {
    _cuitController.dispose();
    _renspaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.select(
      (RegisterEstablishmentBloc bloc) => bloc.state.draft,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              EstablishmentRegisterStrings.stepTwoSectionTitle,
              style: AppTypography.pageTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              EstablishmentRegisterStrings.stepTwoSectionDescription,
              style: AppTypography.pageBodyTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextFormField(
              controller: _cuitController,
              title: EstablishmentRegisterStrings.stepTwoCuitFieldTitle,
              hintText: EstablishmentRegisterStrings.stepTwoCuitFieldHint,
              style: AppTypography.monoValue,
              validation: AppFieldValidation.valid,
              validationMessage: EstablishmentRegisterStrings.stepTwoCuitValidatedCaption,
              onChanged: (value) {
                _updateDraft(draft.copyWith(cuitTitular: value));
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextFormField(
              controller: _renspaController,
              title: EstablishmentRegisterStrings.stepTwoRenspaFieldTitle,
              hintText: EstablishmentRegisterStrings.stepTwoRenspaFieldHint,
              style: AppTypography.monoValue,
              validation: AppFieldValidation.valid,
              onChanged: (value) {
                _updateDraft(draft.copyWith(nroRenspa: value));
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            RenspaBreakdownPanel(nroRenspa: draft.nroRenspa),
            const SizedBox(height: AppSpacing.sm),
            const EstablishmentInfoCallout(
              icon: Icons.shield_outlined,
              title: EstablishmentRegisterStrings.stepTwoSenasaCalloutTitle,
              message: EstablishmentRegisterStrings.stepTwoSenasaCalloutMessage,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppOutlinedButton(
              label: EstablishmentRegisterStrings.stepTwoAddProductionUnitButton,
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _updateDraft(RegisterEstablishmentDraft draft) {
    context.read<RegisterEstablishmentBloc>().add(
      RegisterEstablishmentEvent.draftChanged(draft),
    );
  }
}
