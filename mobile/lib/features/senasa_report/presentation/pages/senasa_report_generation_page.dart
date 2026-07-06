import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_generation_cubit.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_error_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_generation_progress.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_status_indicator.dart';
import 'package:go_router/go_router.dart';

/// Full-screen feedback shown while the SENASA report is being generated.
class SenasaReportGenerationPage extends StatelessWidget {
  /// Creates the SENASA report generation page.
  const SenasaReportGenerationPage({
    required this.request,
    required this.generateReport,
    super.key,
  });

  /// Request selected in the report wizard.
  final SenasaReportRequest request;

  /// Use case that sends the generation request to the backend.
  final GenerateSenasaReportUseCase generateReport;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SenasaReportGenerationCubit(
        generateReport: generateReport,
      )..generate(request),
      child: _SenasaReportGenerationView(request: request),
    );
  }
}

class _SenasaReportGenerationView extends StatelessWidget {
  const _SenasaReportGenerationView({required this.request});

  final SenasaReportRequest request;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SenasaReportGenerationCubit, ResultState<GeneratedSenasaReport>>(
      listener: _onStateChanged,
      child: Scaffold(
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
                          ReportStatusIndicator.loading(),
                          SizedBox(height: AppSpacing.lg),
                          Text(
                            SenasaStrings.generationTitle,
                            style: AppTypography.successTitle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            SenasaStrings.generationDescription,
                            style: AppTypography.successSubtitle,
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
      ),
    );
  }

  void _onStateChanged(
    BuildContext context,
    ResultState<GeneratedSenasaReport> state,
  ) {
    switch (state) {
      case Data<GeneratedSenasaReport>(:final data):
        context.pushReplacement(AppRoutes.senasaReportSuccess, extra: data);
      case ResultError<GeneratedSenasaReport>(:final error):
        context.pushReplacement(
          AppRoutes.senasaReportError,
          extra: SenasaReportErrorArgs(message: error.message, request: request),
        );
      default:
        break;
    }
  }
}
