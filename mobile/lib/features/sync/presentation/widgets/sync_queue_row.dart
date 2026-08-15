import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sync/presentation/mock/sync_status_mock.dart';

/// Fila de la cola de operaciones de sincronización.
class SyncQueueRow extends StatelessWidget {
  /// Crea la fila a partir de una entrada mock de la cola.
  const SyncQueueRow({required this.entry, super.key});

  /// Entrada mock representada por esta fila.
  final SyncQueueEntryMock entry;

  @override
  Widget build(BuildContext context) {
    final (icon, background, foreground) = switch (entry.state) {
      SyncQueueState.syncing => (Icons.sync, AppColors.backgroundSecondary, AppColors.primary),
      SyncQueueState.pending => (Icons.cloud_queue, AppColors.backgroundTertiary, AppColors.textSecondary),
      SyncQueueState.error => (Icons.error_outline, AppColors.errorContainer, AppColors.error),
      SyncQueueState.ok => (Icons.check, AppColors.backgroundSecondary, AppColors.primary),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: background, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxs),
                child: Icon(icon, size: 16, color: foreground),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(entry.operationType, style: AppTypography.mediumEmphasis),
                      ),
                      Text(
                        entry.time,
                        style: AppTypography.monoValue.copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                  Text(
                    entry.detail,
                    style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
                  ),
                  if (entry.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '⚠ ${entry.errorMessage}',
                      style: AppTypography.smallEmphasis.copyWith(color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
