import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

//Strings
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

class DateRangeSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  // Esta función es el "teléfono" para avisarle a la pantalla principal que cambiaron las fechas
  final Function(DateTime newStart, DateTime newEnd) onDatesChanged;

  const DateRangeSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDatesChanged,
  });

  // --- Lógica del Calendario encapsulada acá adentro ---
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF6D4C41),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      DateTime newStart = startDate;
      DateTime newEnd = endDate;

      // Validación cruzada automática
      if (isStart) {
        newStart = picked;
        if (newStart.isAfter(newEnd)) newEnd = newStart;
      } else {
        newEnd = picked;
        if (newEnd.isBefore(newStart)) newStart = newEnd;
      }

      // Le mandamos las fechas actualizadas al padre
      onDatesChanged(newStart, newEnd);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // --- Atajos visuales de diseño ---
  Widget _buildDateShortcutChip(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.06),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
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
          padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text(
            SenasaStrings.dateSelectorTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 /*, color: Colors.black87*/),
          ),
        ),
        AppSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
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

                // Selectores Desde / Hasta
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Desde', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _formatDate(startDate),
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hasta', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _formatDate(endDate),
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
