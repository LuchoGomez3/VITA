import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Weight evolution chart for the animal detail page.
class WeightGainChart extends StatelessWidget {
  /// Creates the animal weight gain chart.
  const WeightGainChart({super.key});

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
          AppLineChart(
            points: AnimalDetailStrings.weightChartPoints,
            minX: 1,
            maxX: 6,
            minY: 200,
            maxY: 450,
            xLabels: AnimalDetailStrings.weightChartMonthLabels,
            yLabelBuilder: (value) => '${value.toInt()}kg',
          ),
        ],
      ),
    );
  }
}
