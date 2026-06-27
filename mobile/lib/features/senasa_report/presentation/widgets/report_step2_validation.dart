import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

/// Paso de validacion visual previo a la generacion del reporte SENASA.
class ReportStep2Validation extends StatelessWidget {
  /// Crea el resumen de validacion para el evento y rango seleccionados.
  const ReportStep2Validation({
    required this.selectedMovement,
    required this.startDate,
    required this.endDate,
    super.key,
  });

  /// Tipo de evento elegido para el reporte.
  final String selectedMovement;

  /// Fecha inicial del periodo reportado.
  final DateTime startDate;

  /// Fecha final del periodo reportado.
  final DateTime endDate;

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.mediumEmphasis),
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: Text(value, style: AppTypography.mediumEmphasis),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedStart =
        '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final formattedEnd =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSuccessBanner(message: SenasaStrings.step2SuccessBanner),
          const SizedBox(height: AppSpacing.lg),

          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.xs),
            child: Text(SenasaStrings.step2SummaryTitle, style: AppTypography.pageTitle),
          ),
          AppSurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxs),
              child: Column(
                children: [
                  _buildSummaryRow(Icons.assignment, SenasaStrings.step2EventLabel, selectedMovement),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Divider(height: AppSpacing.xxxs),
                  ),
                  _buildSummaryRow(Icons.date_range, SenasaStrings.step2PeriodLabel, '$formattedStart - $formattedEnd'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
