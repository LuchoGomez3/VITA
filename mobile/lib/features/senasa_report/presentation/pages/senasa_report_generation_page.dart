import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_generation_progress.dart';

/// Full-screen feedback shown while the SENASA report is being generated.
class SenasaReportGenerationPage extends StatelessWidget {
  /// Creates the SENASA report generation page.
  const SenasaReportGenerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppSpacing.lg * 2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ReportProgressIndicator(),
                        SizedBox(height: AppSpacing.lg),
                        Text(
                          SenasaStrings.generationTitle,
                          style: AppTypography.appBarTitle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          SenasaStrings.generationDescription,
                          style: AppTypography.smallEmphasis,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        ReportGenerationProgress(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReportProgressIndicator extends StatelessWidget {
  const _ReportProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 72,
            child: CircularProgressIndicator(
              value: 0.72,
              strokeWidth: 3,
              backgroundColor: AppColors.backgroundTertiary,
              color: AppColors.primary,
            ),
          ),
          Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.primary,
            size: 30,
          ),
        ],
      ),
    );
  }
}
