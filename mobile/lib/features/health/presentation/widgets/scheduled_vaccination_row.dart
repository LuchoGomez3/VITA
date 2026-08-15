import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/health/presentation/mock/health_mock.dart';
import 'package:frontend_mayoral/features/health/presentation/strings/health_strings.dart';

/// Fila de una vacunación programada: fecha, título, ubicación, cantidad de
/// animales y estado "pendiente".
class ScheduledVaccinationRow extends StatelessWidget {
  /// Crea la fila con la [scheduled] vacunación programada.
  const ScheduledVaccinationRow({required this.scheduled, super.key});

  /// Vacunación programada representada.
  final ScheduledVaccinationMock scheduled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(scheduled.date, style: AppTypography.smallEmphasis),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scheduled.title, style: AppTypography.secondaryEmphasis),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${scheduled.location} · ${scheduled.animalCount} ${HealthStrings.animalCountSuffix}',
                  style: AppTypography.formFieldHelper,
                ),
              ],
            ),
          ),
          AppStatusChip(label: HealthStrings.scheduledPendingLabel),
        ],
      ),
    );
  }
}
