import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/static_map_preview.dart';

/// Paso 3 · Provincia, departamento, localidad y coordenadas del establecimiento.
class EstablishmentRegisterLocationStep extends StatelessWidget {
  /// Crea el paso de ubicación geográfica del establecimiento.
  const EstablishmentRegisterLocationStep({super.key});

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
              EstablishmentRegisterStrings.stepThreeSectionTitle,
              style: AppTypography.pageTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              EstablishmentRegisterStrings.stepThreeSectionDescription,
              style: AppTypography.pageBodyTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDropdownFormField<String>(
                    title: EstablishmentRegisterStrings.stepThreeProvinciaFieldTitle,
                    hintText: EstablishmentRegisterStrings.stepThreeProvinciaFieldTitle,
                    initialValue: draft.provincia.isEmpty ? null : draft.provincia,
                    options: EstablishmentRegisterStrings.stepThreeProvinciaOptions
                        .map((provincia) => AppDropdownOption(value: provincia, label: provincia))
                        .toList(),
                    onChanged: (provincia) {
                      if (provincia == null) {
                        return;
                      }
                      _updateDraft(context, draft.copyWith(provincia: provincia));
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppDropdownFormField<String>(
                    title: EstablishmentRegisterStrings.stepThreeDepartamentoFieldTitle,
                    hintText: EstablishmentRegisterStrings.stepThreeDepartamentoFieldTitle,
                    initialValue: draft.departamento.isEmpty ? null : draft.departamento,
                    options: EstablishmentRegisterStrings.stepThreeDepartamentoOptions
                        .map((departamento) => AppDropdownOption(value: departamento, label: departamento))
                        .toList(),
                    onChanged: (departamento) {
                      if (departamento == null) {
                        return;
                      }
                      _updateDraft(context, draft.copyWith(departamento: departamento));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppDropdownFormField<String>(
              title: EstablishmentRegisterStrings.stepThreeLocalidadFieldTitle,
              hintText: EstablishmentRegisterStrings.stepThreeLocalidadFieldTitle,
              helperText: EstablishmentRegisterStrings.stepThreeLocalidadFieldHelper,
              initialValue: draft.localidad.isEmpty ? null : draft.localidad,
              options: EstablishmentRegisterStrings.stepThreeLocalidadOptions
                  .map((localidad) => AppDropdownOption(value: localidad, label: localidad))
                  .toList(),
              onChanged: (localidad) {
                if (localidad == null) {
                  return;
                }
                _updateDraft(context, draft.copyWith(localidad: localidad));
              },
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              EstablishmentRegisterStrings.stepThreeCoordinatesFieldTitle,
              style: AppTypography.secondaryEmphasis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(child: _ReadOnlyMonoValue(value: _formatCoordinate(draft, draft.latitud))),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _ReadOnlyMonoValue(value: _formatCoordinate(draft, draft.longitud))),
              ],
            ),
            if (draft.ubicacionConfirmadaPorGps) ...[
              const SizedBox(height: AppSpacing.xxs),
              const Row(
                children: [
                  Icon(Icons.check, size: 13, color: AppColors.primary),
                  SizedBox(width: AppSpacing.xxs),
                  Text(
                    EstablishmentRegisterStrings.stepThreeGpsConfirmedCaption,
                    style: AppTypography.formFieldSuccess,
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppOutlinedButton(
              label: EstablishmentRegisterStrings.stepThreeUseCurrentLocationButton,
              icon: const Icon(Icons.my_location),
              onPressed: () {
                _updateDraft(
                  context,
                  draft.copyWith(
                    latitud: mockLocationLatitud,
                    longitud: mockLocationLongitud,
                    ubicacionConfirmadaPorGps: true,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              EstablishmentRegisterStrings.stepThreePreviewLabel,
              style: AppTypography.secondaryEmphasis,
            ),
            const SizedBox(height: AppSpacing.xs),
            const StaticMapPreview(
              child: Center(
                child: Icon(Icons.location_on, size: 32, color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCoordinate(RegisterEstablishmentDraft draft, double value) {
    if (!draft.ubicacionConfirmadaPorGps) {
      return EstablishmentRegisterStrings.stepThreeCoordinateUnconfirmedPlaceholder;
    }
    return '${value.toStringAsFixed(4)}°';
  }

  void _updateDraft(BuildContext context, RegisterEstablishmentDraft draft) {
    context.read<RegisterEstablishmentBloc>().add(
      RegisterEstablishmentEvent.draftChanged(draft),
    );
  }
}

class _ReadOnlyMonoValue extends StatelessWidget {
  const _ReadOnlyMonoValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(value, style: AppTypography.monoValue),
    );
  }
}
