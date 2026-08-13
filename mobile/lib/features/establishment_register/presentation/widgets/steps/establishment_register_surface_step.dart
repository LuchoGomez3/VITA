import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/field_boundary_preview.dart';

/// Paso 4 · Delimitar superficie del establecimiento (réplica visual estática).
class EstablishmentRegisterSurfaceStep extends StatelessWidget {
  /// Crea el paso de delimitación de superficie del establecimiento.
  const EstablishmentRegisterSurfaceStep({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = context.select(
      (RegisterEstablishmentBloc bloc) => bloc.state.draft,
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.backgroundSecondary,
          child: const Row(
            children: [
              Icon(Icons.layers_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  EstablishmentRegisterStrings.stepFourBannerText,
                  style: AppTypography.smallEmphasis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const FieldBoundaryPreview(height: double.infinity),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _SurfaceStatsChip(
                  superficieHectareas: draft.superficieHectareas,
                  cantidadVertices: draft.cantidadVertices,
                ),
              ),
              const Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Column(
                  children: [
                    _ToolButton(
                      icon: Icons.undo,
                      tooltip: EstablishmentRegisterStrings.stepFourUndoTooltip,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _ToolButton(
                      icon: Icons.close,
                      tooltip: EstablishmentRegisterStrings.stepFourClearTooltip,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _ToolButton(
                      icon: Icons.layers_outlined,
                      tooltip: EstablishmentRegisterStrings.stepFourLayerTooltip,
                    ),
                  ],
                ),
              ),
              const Positioned(
                bottom: AppSpacing.md,
                left: 0,
                right: 0,
                child: _HintPill(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurfaceStatsChip extends StatelessWidget {
  const _SurfaceStatsChip({
    required this.superficieHectareas,
    required this.cantidadVertices,
  });

  final double superficieHectareas;
  final int cantidadVertices;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _SurfaceStat(
            label: EstablishmentRegisterStrings.stepFourSurfaceLabel,
            value: '${superficieHectareas.toStringAsFixed(0)} ha',
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: AppSpacing.sm),
          _SurfaceStat(
            label: EstablishmentRegisterStrings.stepFourVerticesLabel,
            value: '$cantidadVertices',
          ),
        ],
      ),
    );
  }
}

class _SurfaceStat extends StatelessWidget {
  const _SurfaceStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.formFieldHelper),
        Text(value, style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary)),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Text(
          EstablishmentRegisterStrings.stepFourHintText,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}
