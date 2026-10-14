import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_formatters.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_ficha_section.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_weighings_tab.dart';

/// Grafico de evolucion de peso usado en la ficha del animal.
class WeightGainChart extends StatelessWidget {
  /// Crea el grafico a partir del historial real de pesajes.
  const WeightGainChart({
    required this.weightHistory,
    super.key,
  });

  /// Pesajes reales ordenados cronologicamente.
  final List<AnimalWeightRecord> weightHistory;

  @override
  Widget build(BuildContext context) {
    final last = weightHistory.lastOrNull;
    final gain = weightHistory.length < 2
        ? null
        : dailyGainBetween(weightHistory[weightHistory.length - 2], weightHistory.last);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnimalFichaSectionTitle(AnimalDetailStrings.weightChartTitle),
          const SizedBox(height: AppSpacing.sm),
          if (last == null)
            const Text(AnimalDetailStrings.noWeightHistory)
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: last.weightKg.displayWeight),
                            TextSpan(
                              text: ' kg',
                              style: AppTypography.mediumEmphasis.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        style: AppTypography.bigTitle.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        AnimalDetailStrings.lastWeighing(DateDisplayFormatter.shortDate(last.date)),
                        style: AppTypography.formFieldHelper,
                      ),
                    ],
                  ),
                ),
                if (gain != null)
                  AppStatusChip(
                    label: AnimalDetailStrings.dailyGain(formatDailyGain(gain)),
                    tone: dailyGainTone(gain),
                    showDot: true,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _WeightHistoryLineChart(weightHistory: weightHistory),
          ],
        ],
      ),
    );
  }
}

class _WeightHistoryLineChart extends StatelessWidget {
  const _WeightHistoryLineChart({required this.weightHistory});

  final List<AnimalWeightRecord> weightHistory;

  @override
  Widget build(BuildContext context) {
    final weights = weightHistory.map((record) => record.weightKg);
    final lowestWeight = weights.reduce((a, b) => a < b ? a : b);
    final highestWeight = weights.reduce((a, b) => a > b ? a : b);
    final minY = (lowestWeight / 50).floorToDouble() * 50;
    final calculatedMaxY = (highestWeight / 50).ceilToDouble() * 50;
    final maxY = calculatedMaxY <= minY ? minY + 50 : calculatedMaxY;
    final maxX = weightHistory.length == 1 ? 2.0 : weightHistory.length.toDouble();

    return AppLineChart(
      points: [
        for (final (index, record) in weightHistory.indexed) AppLineChartPoint(x: index + 1, y: record.weightKg),
      ],
      minX: 1,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      xLabels: {
        for (final (index, record) in weightHistory.indexed) index + 1: DateDisplayFormatter.dayAndMonth(record.date),
      },
      yLabelBuilder: (value) => '${value.toInt()} kg',
    );
  }
}
