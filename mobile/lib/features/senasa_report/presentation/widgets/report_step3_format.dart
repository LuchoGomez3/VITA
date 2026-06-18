import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

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

  Widget _buildFormatOption(BuildContext context, String format, String subtitle, IconData icon) {
    final bool isSelected = selectedFormat == format;
    return InkWell(
      onTap: () => onFormatChanged(format),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
            child: Text(
              SenasaStrings.step3FormatTitle,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          _buildFormatOption(context, 'PDF', SenasaStrings.formatPdfDesc, Icons.picture_as_pdf),
          const SizedBox(height: AppSpacing.sm),
          _buildFormatOption(context, 'CSV', SenasaStrings.formatCsvDesc, Icons.grid_on),
          const SizedBox(height: AppSpacing.sm),
          _buildFormatOption(context, 'TXT', SenasaStrings.formatTxtDesc, Icons.code),
        ],
      ),
    );
  }
}
