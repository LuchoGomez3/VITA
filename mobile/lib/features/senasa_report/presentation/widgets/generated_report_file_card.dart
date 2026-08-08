import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

/// Compact summary card for a generated SENASA report file.
class GeneratedReportFileCard extends StatelessWidget {
  /// Creates the generated file summary.
  const GeneratedReportFileCard({
    required this.report,
    this.onShare,
    super.key,
  });

  /// Backend file returned by the generation endpoint.
  final GeneratedSenasaReport report;

  /// Acción opcional para compartir el archivo desde el historial.
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _FileBadge(extension: _extension),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.filename,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.smallEmphasis.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '$_fileSize • $_generatedDate',
                  style: AppTypography.smallEmphasis,
                ),
              ],
            ),
          ),
          if (onShare != null) ...[
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              tooltip: SenasaStrings.share,
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined),
            ),
          ],
        ],
      ),
    );
  }

  String get _extension {
    final parts = report.filename.split('.');
    if (parts.length < 2) {
      return SenasaStrings.reportFileLabel;
    }
    return parts.last.toUpperCase();
  }

  String get _fileSize {
    final kilobytes = report.bytes.lengthInBytes / 1024;
    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(1)} KB';
    }
    return '${(kilobytes / 1024).toStringAsFixed(1)} MB';
  }

  String get _generatedDate {
    final date = report.generatedAt.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }
}

class _FileBadge extends StatelessWidget {
  const _FileBadge({required this.extension});

  final String extension;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(height: AppSpacing.xxxs),
          Text(
            extension,
            style: AppTypography.smallEmphasis.copyWith(
              color: AppColors.primary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
