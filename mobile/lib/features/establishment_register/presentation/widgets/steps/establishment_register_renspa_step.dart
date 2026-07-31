import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
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

  late CuitValidationError? _cuitError;
  late RenspaValidationError? _renspaError;

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegisterEstablishmentBloc>().state.draft;
    _cuitController.text = draft.cuitTitular;
    _renspaController.text = draft.nroRenspa;
    _cuitError = CuitInputFormatter.validationError(draft.cuitTitular);
    _renspaError = RenspaInputFormatter.validationError(draft.nroRenspa);
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
    final renspaConflict = context.select(
      (RegisterEstablishmentBloc bloc) => switch (bloc.state.submitResult) {
        ResultError<RegisteredEstablishment>(:final error) => error.code == DomainErrorCode.conflict,
        _ => false,
      },
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
              keyboardType: TextInputType.number,
              inputFormatters: [
                CuitInputFormatter(
                  onValidationChanged: (error) => setState(() => _cuitError = error),
                ),
              ],
              validation: _cuitError == null ? AppFieldValidation.valid : AppFieldValidation.invalid,
              validationMessage: _cuitValidationMessage,
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
              keyboardType: TextInputType.number,
              inputFormatters: [
                RenspaInputFormatter(
                  onValidationChanged: (error) => setState(() => _renspaError = error),
                ),
              ],
              validation: _renspaError == null ? AppFieldValidation.valid : AppFieldValidation.invalid,
              validationMessage: _renspaValidationMessage,
              onChanged: (value) {
                _updateDraft(draft.copyWith(nroRenspa: value));
              },
            ),
            if (renspaConflict) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        EstablishmentRegisterStrings.renspaConflictMessage,
                        style: AppTypography.smallEmphasis.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  String get _cuitValidationMessage => switch (_cuitError) {
    null => EstablishmentRegisterStrings.stepTwoCuitValidatedCaption,
    CuitValidationError.invalidCheckDigit => EstablishmentRegisterStrings.stepTwoCuitInvalidCheckDigitMessage,
    _ => EstablishmentRegisterStrings.stepTwoCuitIncompleteMessage,
  };

  String get _renspaValidationMessage => switch (_renspaError) {
    null => EstablishmentRegisterStrings.stepTwoRenspaValidFormatMessage,
    _ => EstablishmentRegisterStrings.stepTwoRenspaIncompleteMessage,
  };

  void _updateDraft(RegisterEstablishmentDraft draft) {
    context.read<RegisterEstablishmentBloc>().add(
      RegisterEstablishmentEvent.draftChanged(draft),
    );
  }
}
