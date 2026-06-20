import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
//widgets
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/date_range_selector.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/event_type_selector.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/establishment_data_form.dart';

//Strings
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

class ReportStep1Filters extends StatelessWidget {
  final String selectedMovement;
  final ValueChanged<String> onMovementChanged;
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime start, DateTime end) onDatesChanged;
  final String? selectedOrigen;
  final ValueChanged<String?> onOrigenChanged;

  const ReportStep1Filters({
    super.key,
    required this.selectedMovement,
    required this.onMovementChanged,
    required this.startDate,
    required this.endDate,
    required this.onDatesChanged,
    required this.selectedOrigen,
    required this.onOrigenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSubsectionTitleAndDescription(
            title: SenasaStrings.step1SectionEvent,
            description: SenasaStrings.step1SectionEventDesc,
          ),

          DateRangeSelector(
            startDate: startDate,
            endDate: endDate,
            onDatesChanged: onDatesChanged,
          ),
          const SizedBox(height: AppSpacing.xs),

          EventTypeSelector(
            selectedMovement: selectedMovement,
            onChanged: onMovementChanged,
          ),
          const SizedBox(height: AppSpacing.xs),

          EstablishmentSelector(
            selectedOrigen: selectedOrigen,
            onOrigenChanged: onOrigenChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
