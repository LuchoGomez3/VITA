import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/date_range_selector.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/establishment_data_form.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/event_type_selector.dart';

/// Displays the filters used to select records for a SENASA report.
class ReportStep1Filters extends StatelessWidget {
  /// Creates the first step of the SENASA report flow.
  const ReportStep1Filters({
    required this.formKey,
    required this.establishments,
    required this.selectedMovement,
    required this.onMovementChanged,
    required this.startDate,
    required this.endDate,
    required this.onDatesChanged,
    required this.selectedOrigin,
    required this.onOriginChanged,
    super.key,
  });

  /// Establishments available to the authenticated user.
  final List<SenasaEstablishment> establishments;

  /// Key used to validate the first-step fields.
  final GlobalKey<FormState> formKey;

  /// Currently selected movement type.
  final String selectedMovement;

  /// Called when the movement type changes.
  final ValueChanged<String> onMovementChanged;

  /// Start date of the report period.
  final DateTime startDate;

  /// End date of the report period.
  final DateTime endDate;

  /// Called when the report period changes.
  final void Function(DateTime start, DateTime end) onDatesChanged;

  /// Currently selected establishment.
  final String? selectedOrigin;

  /// Called when the establishment changes.
  final ValueChanged<String?> onOriginChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
              establishments: establishments,
              selectedOrigin: selectedOrigin,
              onOriginChanged: onOriginChanged,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}
