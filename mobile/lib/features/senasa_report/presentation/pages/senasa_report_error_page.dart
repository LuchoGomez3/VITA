import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_status_indicator.dart';
import 'package:go_router/go_router.dart';

/// Arguments required to render and retry a failed report generation.
class SenasaReportErrorArgs {
  /// Creates error page arguments.
  const SenasaReportErrorArgs({
    required this.message,
    required this.request,
  });

  /// Error message shown to the user.
  final String message;

  /// Original request used to retry generation.
  final SenasaReportRequest request;
}

/// Result page shown when a SENASA report generation fails.
class SenasaReportErrorPage extends StatelessWidget {
  /// Creates the error page.
  const SenasaReportErrorPage({
    required this.args,
    super.key,
  });

  /// Error data passed from the loading page.
  final SenasaReportErrorArgs args;

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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ReportStatusIndicator.error(),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          SenasaStrings.errorTitle,
                          style: AppTypography.successTitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          SenasaStrings.errorDescription,
                          style: AppTypography.successSubtitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppSurfaceCard(
                          child: Text(
                            args.message,
                            style: AppTypography.mediumEmphasis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppFilledButton(
                          label: SenasaStrings.retryGeneration,
                          icon: const Icon(Icons.refresh),
                          onPressed: () => context.pushReplacement(
                            AppRoutes.senasaReportGeneration,
                            extra: args.request,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(SenasaStrings.backToCompliance),
                        ),
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
