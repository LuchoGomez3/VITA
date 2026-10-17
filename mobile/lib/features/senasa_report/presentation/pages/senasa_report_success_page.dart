import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/generated_report_file_card.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// Result page shown when a SENASA report is generated successfully.
class SenasaReportSuccessPage extends StatelessWidget {
  /// Creates the success page.
  const SenasaReportSuccessPage({
    required this.report,
    super.key,
  });

  /// Generated report returned by the backend.
  final GeneratedSenasaReport report;

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
                        const AppStatusIndicator(
                          icon: Icons.check,
                          color: AppColors.primary,
                          isLoading: false,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          SenasaStrings.successTitle,
                          style: AppTypography.successTitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          SenasaStrings.successDescription,
                          style: AppTypography.successSubtitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        GeneratedReportFileCard(report: report),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          SenasaStrings.includedAnimals(report.animalCount),
                          style: AppTypography.mediumEmphasis,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ReportActions(report: report),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: () => context.go(
                            AppRoutes.senasaMenu,
                            extra: report.generatedAt.microsecondsSinceEpoch,
                          ),
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

class _ReportActions extends StatelessWidget {
  const _ReportActions({required this.report});

  final GeneratedSenasaReport report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactActionButton(
            label: SenasaStrings.download,
            icon: Icons.download,
            isPrimary: true,
            onPressed: () => unawaited(_shareFile()),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _CompactActionButton(
            label: SenasaStrings.share,
            icon: Icons.arrow_forward,
            onPressed: () => unawaited(_shareFile()),
          ),
        ),
      ],
    );
  }

  Future<void> _shareFile() async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            report.bytes,
            mimeType: report.mediaType,
            name: report.filename,
          ),
        ],
        fileNameOverrides: [report.filename],
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isPrimary ? AppColors.onPrimary : AppColors.textPrimary;
    final backgroundColor = isPrimary ? AppColors.primary : AppColors.surface;

    return SizedBox(
      height: 68,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(
              color: isPrimary ? AppColors.primary : AppColors.border,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: AppSpacing.xxs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppTypography.smallEmphasis.copyWith(
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
