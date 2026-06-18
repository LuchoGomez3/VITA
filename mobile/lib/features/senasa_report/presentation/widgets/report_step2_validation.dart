import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
//Strings
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

class ReportStep2Validation extends StatelessWidget {
  final String selectedMovement;
  final DateTime startDate;
  final DateTime endDate;

  const ReportStep2Validation({
    super.key,
    required this.selectedMovement,
    required this.startDate,
    required this.endDate,
  });

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedStart =
        '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final String formattedEnd =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.teal.shade600, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    SenasaStrings.step2SuccessBanner,
                    style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(SenasaStrings.step2SummaryTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          AppSurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  _buildSummaryRow(Icons.assignment, SenasaStrings.step2EventLabel, selectedMovement),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: Divider(height: 1)),
                  _buildSummaryRow(Icons.date_range, SenasaStrings.step2PeriodLabel, '$formattedStart - $formattedEnd'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: Divider(height: 1)),
                  _buildSummaryRow(Icons.pets, SenasaStrings.step2AnimalsLabel, '42 de la firma'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: Divider(height: 1)),
                  _buildSummaryRow(Icons.category, SenasaStrings.step2CategoriesLabel, 'Terneros (12), Novillos (30)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
