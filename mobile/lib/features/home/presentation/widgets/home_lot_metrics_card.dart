import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';

/// Representa el peso promedio y la dispersión de cada lote.
class HomeLotMetricsCard extends StatelessWidget {
  /// Crea la tarjeta con las métricas agrupadas por lote.
  const HomeLotMetricsCard({required this.lots, super.key});

  /// Lotes calculados por la capa de dominio y datos.
  final List<LotWeightMetric> lots;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomeStrings.weightByLot,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          if (lots.isEmpty)
            const Text(HomeStrings.noAnimals)
          else
            for (final (index, lot) in lots.indexed) ...[
              _LotMetricRow(lot: lot),
              if (index < lots.length - 1) const Divider(),
            ],
        ],
      ),
    );
  }
}

class _LotMetricRow extends StatelessWidget {
  const _LotMetricRow({required this.lot});

  final LotWeightMetric lot;

  @override
  Widget build(BuildContext context) {
    final hasWeight = lot.animalsWithWeight > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lot.name, style: AppTypography.mediumEmphasis),
                Text(
                  '${lot.animals} animales · '
                  '${lot.animalsWithWeight} ${HomeStrings.withWeight}',
                  style: AppTypography.smallEmphasis.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hasWeight ? '${lot.averageWeightKg.toStringAsFixed(1)} kg' : HomeStrings.noData,
                style: AppTypography.mediumEmphasis,
              ),
              if (hasWeight)
                Text(
                  '± ${lot.weightStandardDeviationKg.toStringAsFixed(1)} kg',
                  style: AppTypography.smallEmphasis.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
