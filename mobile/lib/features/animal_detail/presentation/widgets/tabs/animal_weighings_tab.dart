import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_formatters.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_ficha_section.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/weight_gain_chart.dart';

/// Pestaña Pesajes (diseño "Ficha · Pesajes"): evolución del peso y el
/// histórico, del más reciente al más antiguo, con la ganancia diaria (GPD)
/// respecto del pesaje anterior.
class AnimalWeighingsTab extends StatelessWidget {
  /// Crea la pestaña para [animal].
  const AnimalWeighingsTab({required this.animal, super.key});

  /// Animal de la ficha.
  final AnimalDetail animal;

  @override
  Widget build(BuildContext context) {
    final history = animal.weightHistory;
    final rows = [
      for (var index = history.length - 1; index >= 0; index--)
        _WeighingRow(record: history[index], previous: index > 0 ? history[index - 1] : null),
    ];

    return ListView(
      // Lugar para el botón flotante.
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
      children: [
        WeightGainChart(weightHistory: history),
        if (rows.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          AnimalFichaSectionTitle(AnimalDetailStrings.weighingHistoryTitle(rows.length)),
          const SizedBox(height: AppSpacing.xs),
          for (final row in rows) ...[row, const SizedBox(height: AppSpacing.xs)],
        ],
      ],
    );
  }
}

/// GPD entre dos pesajes, en kg/día, o `null` si no hay días entre ellos.
double? dailyGainBetween(AnimalWeightRecord previous, AnimalWeightRecord current) {
  final days = current.date.difference(previous.date).inHours / 24;
  if (days <= 0) {
    return null;
  }
  return (current.weightKg - previous.weightKg) / days;
}

/// Verde si el animal ganó peso (o se mantuvo), rojo si perdió.
AppStatusChipTone dailyGainTone(double value) => value < 0 ? AppStatusChipTone.error : AppStatusChipTone.success;

/// GPD con signo y coma decimal: `+0,85`.
String formatDailyGain(double value) {
  final sign = value >= 0 ? '+' : '−';
  return '$sign${value.abs().toStringAsFixed(2).replaceAll('.', ',')}';
}

class _WeighingRow extends StatelessWidget {
  const _WeighingRow({required this.record, required this.previous});

  final AnimalWeightRecord record;
  final AnimalWeightRecord? previous;

  @override
  Widget build(BuildContext context) {
    final before = previous;
    final gain = before == null ? null : dailyGainBetween(before, record);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateDisplayFormatter.shortDate(record.date),
                  style: AppTypography.smallEmphasis.copyWith(color: AppColors.textPrimary),
                ),
                Text(record.method.label, style: AppTypography.formFieldHelper),
              ],
            ),
          ),
          Text(
            '${record.weightKg.displayWeight} kg',
            style: AppTypography.mediumEmphasis.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (gain != null) ...[
            const SizedBox(width: AppSpacing.sm),
            AppStatusChip(label: formatDailyGain(gain), tone: dailyGainTone(gain)),
          ],
        ],
      ),
    );
  }
}
