import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

/// Paso 1 · Identificación del establecimiento (nombre, descripción, tipo de producción).
class EstablishmentRegisterIdentificationStep extends StatefulWidget {
  /// Crea el paso de identificación del establecimiento.
  const EstablishmentRegisterIdentificationStep({super.key});

  @override
  State<EstablishmentRegisterIdentificationStep> createState() => _EstablishmentRegisterIdentificationStepState();
}

class _EstablishmentRegisterIdentificationStepState extends State<EstablishmentRegisterIdentificationStep> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegisterEstablishmentBloc>().state.draft;
    _nombreController.text = draft.nombre;
    _descripcionController.text = draft.descripcion;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
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
              EstablishmentRegisterStrings.stepOneSectionTitle,
              style: AppTypography.pageTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              EstablishmentRegisterStrings.stepOneSectionDescription,
              style: AppTypography.pageBodyTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextFormField(
              controller: _nombreController,
              title: EstablishmentRegisterStrings.stepOneNameFieldTitle,
              hintText: EstablishmentRegisterStrings.stepOneNameFieldHint,
              helperText: EstablishmentRegisterStrings.stepOneNameFieldHelper,
              maxCharacters: 60,
              onChanged: (value) {
                _updateDraft(draft.copyWith(nombre: value));
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextFormField(
              controller: _descripcionController,
              titleWidget: const Text.rich(
                TextSpan(
                  text: EstablishmentRegisterStrings.stepOneDescriptionFieldTitle,
                  style: AppTypography.secondaryEmphasis,
                  children: [
                    TextSpan(
                      text: EstablishmentRegisterStrings.stepOneDescriptionFieldOptionalSuffix,
                      style: AppTypography.formFieldHelper,
                    ),
                  ],
                ),
              ),
              hintText: EstablishmentRegisterStrings.stepOneDescriptionFieldHint,
              maxLines: 4,
              onChanged: (value) {
                _updateDraft(draft.copyWith(descripcion: value));
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppChoiceSelector<String>(
              title: EstablishmentRegisterStrings.stepOneProductionTypeTitle,
              isSelected: draft.tiposProduccion.contains,
              options: EstablishmentRegisterStrings.stepOneProductionTypeOptions
                  .map(
                    (type) => AppChoiceOption(
                      value: type,
                      label: type,
                    ),
                  )
                  .toList(),
              onChanged: (type) => _toggleProductionType(draft, type),
            ),
            const SizedBox(height: AppSpacing.xxs),
            const Text(
              EstablishmentRegisterStrings.stepOneProductionTypeHelper,
              style: AppTypography.formFieldHelper,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleProductionType(RegisterEstablishmentDraft draft, String type) {
    final updated = Set<String>.from(draft.tiposProduccion);
    if (updated.contains(type)) {
      updated.remove(type);
    } else {
      updated.add(type);
    }
    _updateDraft(draft.copyWith(tiposProduccion: updated));
  }

  void _updateDraft(RegisterEstablishmentDraft draft) {
    context.read<RegisterEstablishmentBloc>().add(
      RegisterEstablishmentEvent.draftChanged(draft),
    );
  }
}
