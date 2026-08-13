import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/presentation/mock/paddock_mock.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Leyenda flotante de densidad de carga mostrada sobre el mapa de potreros.
class FieldDensityLegend extends StatelessWidget {
  /// Crea la leyenda de densidad.
  const FieldDensityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(FieldStrings.densityLegendTitle, style: AppTypography.smallEmphasis),
            const SizedBox(height: AppSpacing.xxs),
            _legendRow(PaddockDensity.high, FieldStrings.densityHigh),
            _legendRow(PaddockDensity.medium, FieldStrings.densityMedium),
            _legendRow(PaddockDensity.low, FieldStrings.densityLow),
            _legendRow(PaddockDensity.none, FieldStrings.densityNone),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(PaddockDensity density, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: density.color, borderRadius: BorderRadius.circular(2)),
            child: const SizedBox(width: 10, height: 10),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(label, style: AppTypography.formFieldHelper),
        ],
      ),
    );
  }
}
