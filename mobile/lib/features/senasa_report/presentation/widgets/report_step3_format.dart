import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/app_borders.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/core/widgets/fields/fields.dart';

//Strings
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

class ReportStep3Format extends StatelessWidget {
  final String selectedFormat;
  final ValueChanged<String> onFormatChanged;

  const ReportStep3Format({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.sm),
            child: Text(
              SenasaStrings.step3FormatTitle,
              style: AppTypography.pageTitle,
            ),
          ),
          // Seleccion de formato
          AppSelectableCard<String>(
            value: SenasaStrings.step3pdf, 
            groupValue: selectedFormat, 
            title: SenasaStrings.step3pdf, 
            subtitle: SenasaStrings.formatPdfDesc, 
            icon: Icons.picture_as_pdf, 
            onChanged: onFormatChanged
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSelectableCard<String>(
            value: SenasaStrings.step3csv, 
            groupValue: selectedFormat, 
            title: SenasaStrings.step3csv, 
            subtitle: SenasaStrings.formatCsvDesc, 
            icon: Icons.grid_on, 
            onChanged: onFormatChanged
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSelectableCard<String>(
            value: SenasaStrings.step3txt, 
            groupValue: selectedFormat, 
            title: SenasaStrings.step3txt, 
            subtitle: SenasaStrings.formatTxtDesc, 
            icon: Icons.code, 
            onChanged: onFormatChanged
            ),
            const SizedBox(height: AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.sm),
              child: Text(
                SenasaStrings.responsableName,
                style: AppTypography.pageTitle,
              ),
            ),
            const AppTextFormField(
              hintText: SenasaStrings.formName
              ),const SizedBox(height: AppSpacing.sm),
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.sm),
              child: Text(
                SenasaStrings.responsableDNI,
                style: AppTypography.pageTitle,
              ),
            ),
            //const SizedBox(height: AppSpacing.sm),
            const AppTextFormField(
              hintText: SenasaStrings.formDNI
              ),
        ],
      ),
    );
  }
}
