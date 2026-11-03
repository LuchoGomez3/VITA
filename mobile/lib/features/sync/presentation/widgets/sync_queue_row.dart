import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';

/// Fila de la cola de operaciones de sincronización.
class SyncQueueRow extends StatelessWidget {
  /// Crea la fila de una operación pendiente.
  const SyncQueueRow({required this.operation, super.key});

  /// Operación representada por esta fila.
  final SyncQueueOperation operation;

  @override
  Widget build(BuildContext context) {
    final (icon, background, foreground) = switch (operation.state) {
      SyncOperationState.sending => (Icons.sync, AppColors.backgroundSecondary, AppColors.primary),
      SyncOperationState.waiting => (Icons.cloud_queue, AppColors.backgroundTertiary, AppColors.textSecondary),
      SyncOperationState.retrying => (Icons.schedule, AppColors.syncPendingContainer, AppColors.syncPending),
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
                    children: [
                      Expanded(
                        child: Text(
                          SyncStatusStrings.operationKind(operation.kind),
                          style: AppTypography.mediumEmphasis,
                        ),
                      ),
                      Text(
                        _formatTime(operation.queuedAt),
                        style: AppTypography.monoValue.copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                  Text(
                    SyncStatusStrings.operationState(operation),
                    style: AppTypography.smallEmphasis.copyWith(
                      color: operation.state == SyncOperationState.retrying
                          ? AppColors.syncPending
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `HH:mm` si es de hoy; `dd/MM HH:mm` si quedó de otro día.
  static String _formatTime(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    String two(int number) => number.toString().padLeft(2, '0');
    final time = '${two(local.hour)}:${two(local.minute)}';
    final isToday = local.year == now.year && local.month == now.month && local.day == now.day;
    return isToday ? time : '${two(local.day)}/${two(local.month)} $time';
  }
}
