import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

/// Selector de rango temporal usado para parametrizar reportes SENASA.
class DateRangeSelector extends StatelessWidget {
  /// Crea el selector con fechas iniciales y callback de cambio.
  const DateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.onDatesChanged,
    super.key,
  });

  /// Fecha inicial seleccionada.
  final DateTime startDate;

  /// Fecha final seleccionada.
  final DateTime endDate;

  /// Notifica el nuevo rango cuando cambia cualquiera de las fechas.
  final void Function(DateTime newStart, DateTime newEnd) onDatesChanged;

  Widget _buildDateShortcutChip(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(
          label,
          style: AppTypography.datePickerChip,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          elevation: 6,
          shadowColor: AppColors.cardShadow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                SenasaStrings.dateSelectorTitle,
                style: AppTypography.pageTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildDateShortcutChip(context, SenasaStrings.dateSelectorToday, () {
                      onDatesChanged(DateTime.now(), DateTime.now());
                    }),
                    const SizedBox(width: AppSpacing.xs),
                    _buildDateShortcutChip(context, SenasaStrings.dateSelectorLast7Days, () {
                      onDatesChanged(DateTime.now().subtract(const Duration(days: 7)), DateTime.now());
                    }),
                    const SizedBox(width: AppSpacing.xs),
                    _buildDateShortcutChip(context, SenasaStrings.dateSelectorLast30Days, () {
                      onDatesChanged(DateTime.now().subtract(const Duration(days: 30)), DateTime.now());
                    }),
                    const SizedBox(width: AppSpacing.xs),
                    _buildDateShortcutChip(context, SenasaStrings.dateSelectorCurrentMonth, () {
                      final now = DateTime.now();
                      onDatesChanged(DateTime(now.year, now.month), now);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppDateFormField(
                      title: SenasaStrings.dateSelectorFromTitle,
                      hintText: SenasaStrings.dateSelectorFieldHint,
                      value: startDate,
                      onChanged: (newStart) {
                        var finalEnd = endDate;
                        if (newStart.isAfter(finalEnd)) finalEnd = newStart;
                        onDatesChanged(newStart, finalEnd);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppDateFormField(
                      title: SenasaStrings.dateSelectorToTitle,
                      hintText: SenasaStrings.dateSelectorFieldHint,
                      value: endDate,
                      onChanged: (newEnd) {
                        var finalStart = startDate;
                        if (newEnd.isBefore(finalStart)) finalStart = newEnd;
                        onDatesChanged(finalStart, newEnd);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
