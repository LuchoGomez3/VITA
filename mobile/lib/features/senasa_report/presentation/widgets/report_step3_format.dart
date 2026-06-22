import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/validators/validators.dart';
import 'package:frontend_mayoral/core/widgets/fields/fields.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

/// Displays the output format and responsible person fields for a SENASA report.
class ReportStep3Format extends StatelessWidget {
  /// Creates the third step of the SENASA report flow.
  const ReportStep3Format({
    required this.formKey,
    required this.selectedFormat,
    required this.onFormatChanged,
    required this.responsibleNameController,
    required this.responsibleDniController,
    super.key,
  });

  /// Key used to validate the responsible person fields.
  final GlobalKey<FormState> formKey;

  /// Currently selected report format.
  final String selectedFormat;

  /// Called when the report format changes.
  final ValueChanged<String> onFormatChanged;

  /// Controller for the responsible person's full name.
  final TextEditingController responsibleNameController;

  /// Controller for the responsible person's DNI.
  final TextEditingController responsibleDniController;

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
            const Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xxs,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                SenasaStrings.step3FormatTitle,
                style: AppTypography.pageTitle,
              ),
            ),
            AppSelectableCard<String>(
              value: SenasaStrings.step3pdf,
              groupValue: selectedFormat,
              title: SenasaStrings.step3pdf,
              subtitle: SenasaStrings.formatPdfDesc,
              icon: Icons.picture_as_pdf,
              onChanged: onFormatChanged,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSelectableCard<String>(
              value: SenasaStrings.step3csv,
              groupValue: selectedFormat,
              title: SenasaStrings.step3csv,
              subtitle: SenasaStrings.formatCsvDesc,
              icon: Icons.grid_on,
              onChanged: onFormatChanged,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSelectableCard<String>(
              value: SenasaStrings.step3txt,
              groupValue: selectedFormat,
              title: SenasaStrings.step3txt,
              subtitle: SenasaStrings.formatTxtDesc,
              icon: Icons.code,
              onChanged: onFormatChanged,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextFormField(
              controller: responsibleNameController,
              title: SenasaStrings.responsableName,
              hintText: SenasaStrings.formName,
              textInputAction: TextInputAction.next,
              validator: (value) => FormValidators.requiredField(
                value,
                message: SenasaStrings.responsibleNameRequired,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextFormField(
              controller: responsibleDniController,
              title: SenasaStrings.responsableDNI,
              hintText: SenasaStrings.formDNI,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: (value) => FormValidators.requiredField(
                value,
                message: SenasaStrings.responsibleDniRequired,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
