import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

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
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AnimalDetailStrings.weightChartTitle,
            style: AppTypography.pageTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          if (weightHistory.isEmpty)
            const Text(AnimalDetailStrings.noWeightHistory)
          else
            _WeightHistoryLineChart(weightHistory: weightHistory),
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
