import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart'; // Acá debería estar exportado AppDateFormField

//Strings
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

class DateRangeSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime newStart, DateTime newEnd) onDatesChanged;

  const DateRangeSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDatesChanged,
  });

  // --- Atajos visuales de diseño ---
  Widget _buildDateShortcutChip(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
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
        const Padding(
          padding: EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.xxs),
          child: Text(
            SenasaStrings.dateSelectorTitle,
            style: AppTypography.pageTitle,
          ),
        ),
        AppSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxs), // Ajustado según tu diseño
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Atajos temporales
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildDateShortcutChip(context, SenasaStrings.dateSelectorToday, () {
                        onDatesChanged(DateTime.now(), DateTime.now());
                      }),
                      const SizedBox(width: 8),
                      _buildDateShortcutChip(context, SenasaStrings.dateSelectorLast7Days, () {
                        onDatesChanged(DateTime.now().subtract(const Duration(days: 7)), DateTime.now());
                      }),
                      const SizedBox(width: 8),
                      _buildDateShortcutChip(context, SenasaStrings.dateSelectorLast30Days, () {
                        onDatesChanged(DateTime.now().subtract(const Duration(days: 30)), DateTime.now());
                      }),
                      const SizedBox(width: 8),
                      _buildDateShortcutChip(context, SenasaStrings.dateSelectorCurrentMonth, () {
                        final now = DateTime.now();
                        onDatesChanged(DateTime(now.year, now.month, 1), now);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Selectores Desde / Hasta usando el componente del Core
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppDateFormField(
                        title: 'Desde', // O reemplazalo por un string de SenasaStrings
                        hintText: 'Fecha',
                        value: startDate,
                        onChanged: (newStart) {
                          DateTime finalEnd = endDate;
                          // Validación cruzada: Si "Desde" es mayor que "Hasta", igualamos "Hasta"
                          if (newStart.isAfter(finalEnd)) finalEnd = newStart;
                          onDatesChanged(newStart, finalEnd);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppDateFormField(
                        title: 'Hasta', // O reemplazalo por un string de SenasaStrings
                        hintText: 'Fecha',
                        value: endDate,
                        onChanged: (newEnd) {
                          DateTime finalStart = startDate;
                          // Validación cruzada: Si "Hasta" es menor que "Desde", igualamos "Desde"
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
        ),
      ],
    );
  }
}
