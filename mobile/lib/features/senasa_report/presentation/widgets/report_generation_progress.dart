import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

/// Displays the current tasks involved in creating a SENASA report.
class ReportGenerationProgress extends StatelessWidget {
  /// Creates the report generation progress list.
  const ReportGenerationProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _GenerationTask(
          label: SenasaStrings.validatingData,
          status: _GenerationTaskStatus.completed,
        ),
        SizedBox(height: AppSpacing.xs),
        _GenerationTask(
          label: SenasaStrings.sortingEvents,
          status: _GenerationTaskStatus.completed,
        ),
        SizedBox(height: AppSpacing.xs),
        _GenerationTask(
          label: SenasaStrings.compilingPdf,
          status: _GenerationTaskStatus.inProgress,
        ),
        SizedBox(height: AppSpacing.xs),
        _GenerationTask(
          label: SenasaStrings.preparingDownload,
          status: _GenerationTaskStatus.pending,
        ),
      ],
    );
  }
}

enum _GenerationTaskStatus { completed, inProgress, pending }

class _GenerationTask extends StatelessWidget {
  const _GenerationTask({required this.label, required this.status});

  final String label;
  final _GenerationTaskStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          _TaskStatusIcon(status: status),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.smallEmphasis.copyWith(
                color: status == _GenerationTaskStatus.pending
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (status == _GenerationTaskStatus.inProgress) ...[
            const SizedBox(width: AppSpacing.xs),
            const _InProgressBadge(),
          ],
        ],
      ),
    );
  }
}

class _TaskStatusIcon extends StatelessWidget {
  const _TaskStatusIcon({required this.status});

  final _GenerationTaskStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      _GenerationTaskStatus.completed => const Icon(
        Icons.check_circle,
        color: AppColors.primary,
        size: 22,
      ),
      _GenerationTaskStatus.inProgress => Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.sync,
          color: AppColors.primary,
          size: 14,
        ),
      ),
      _GenerationTaskStatus.pending => const Icon(
        Icons.circle,
        color: AppColors.backgroundTertiary,
        size: 22,
      ),
    };
  }
}

class _InProgressBadge extends StatelessWidget {
  const _InProgressBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        SenasaStrings.inProgress,
        style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
      ),
    );
  }
}
