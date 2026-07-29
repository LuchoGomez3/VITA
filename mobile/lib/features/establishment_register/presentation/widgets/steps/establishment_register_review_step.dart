import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/establishment_info_callout.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/establishment_review_section.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/field_boundary_preview.dart';

/// Revisar y crear · resumen final antes de enviar el registro.
class EstablishmentRegisterReviewStep extends StatelessWidget {
  /// Crea el paso de revisión final del establecimiento.
  const EstablishmentRegisterReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = context.select(
      (RegisterEstablishmentBloc bloc) => bloc.state.draft,
    );

    return SafeArea(
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
            EstablishmentReviewSection(
              order: 1,
              title: EstablishmentRegisterStrings.reviewSectionOneTitle,
              onEdit: () => _editStep(context, RegisterEstablishmentStep.identification),
              rows: [
                EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewNombreLabel,
                  value: draft.nombre,
                ),
                EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewProduccionLabel,
                  value: draft.tiposProduccion.join(' · '),
                ),
                EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewDescripcionLabel,
                  value: draft.descripcion,
                  isMuted: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            EstablishmentReviewSection(
              order: 2,
              title: EstablishmentRegisterStrings.reviewSectionTwoTitle,
              onEdit: () => _editStep(context, RegisterEstablishmentStep.renspa),
              rows: [
                const EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewTitularLabel,
                  value: EstablishmentRegisterStrings.reviewOwnerNameMock,
                ),
                EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewCuitLabel,
                  value: draft.cuitTitular,
                  isMono: true,
                ),
                EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewRenspaLabel,
                  value: draft.nroRenspa,
                  isMono: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            EstablishmentReviewSection(
              order: 3,
              title: EstablishmentRegisterStrings.reviewSectionThreeTitle,
              onEdit: () => _editStep(context, RegisterEstablishmentStep.location),
              rows: [
                EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewProvinciaLabel,
                  value: draft.provincia,
                ),
                EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewDepartamentoLabel,
                  value: draft.departamento,
                ),
                EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewLocalidadLabel,
                  value: draft.localidad,
                ),
                EstablishmentReviewRow(
                  label: EstablishmentRegisterStrings.reviewCoordenadasLabel,
                  value: '${draft.latitud.toStringAsFixed(4)}° / ${draft.longitud.toStringAsFixed(4)}°',
                  isMono: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            EstablishmentReviewSection(
              order: 4,
              title: EstablishmentRegisterStrings.reviewSectionFourTitle,
              onEdit: () => _editStep(context, RegisterEstablishmentStep.surface),
              rows: const [],
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldBoundaryPreview(height: 120, showVertexLabels: false),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _ReviewChip(
                        label: '${draft.superficieHectareas.toStringAsFixed(0)} ha',
                        isHighlighted: true,
                      ),
                      const _ReviewChip(
                        label: EstablishmentRegisterStrings.reviewUnidadProductivaChipLabel,
                      ),
                      _ReviewChip(label: '${draft.cantidadVertices} vértices'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const EstablishmentInfoCallout(
              icon: Icons.shield_outlined,
              title: EstablishmentRegisterStrings.reviewOwnerNoteTitle,
              message: EstablishmentRegisterStrings.reviewOwnerNoteMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _editStep(BuildContext context, RegisterEstablishmentStep step) {
    context.read<RegisterEstablishmentBloc>().add(
      RegisterEstablishmentEvent.stepRequested(step),
    );
  }
}

class _ReviewChip extends StatelessWidget {
  const _ReviewChip({required this.label, this.isHighlighted = false});

  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.backgroundSecondary : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.smallEmphasis.copyWith(
          color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
