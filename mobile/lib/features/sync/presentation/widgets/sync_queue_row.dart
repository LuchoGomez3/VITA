import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';
import 'package:frontend_mayoral/features/sync/presentation/widgets/sync_record_tile.dart';

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

    return SyncRecordTile(
      icon: icon,
      iconBackground: background,
      iconColor: foreground,
      title: SyncStatusStrings.operationKind(operation.kind),
      time: operation.queuedAt,
      detail: SyncStatusStrings.operationState(operation),
      detailColor: operation.state == SyncOperationState.retrying ? AppColors.syncPending : AppColors.textHint,
    );
  }
}

/// Fila de un registro que el backend rechazó.
class SyncRejectedRow extends StatelessWidget {
  /// Crea la fila.
  const SyncRejectedRow({required this.record, super.key});

  /// Registro rechazado.
  final SyncRejectedRecord record;

  @override
  Widget build(BuildContext context) {
    return SyncRecordTile(
      icon: Icons.error_outline,
      iconBackground: AppColors.errorContainer,
      iconColor: AppColors.error,
      title: SyncStatusStrings.operationKind(record.kind),
      time: record.recordedAt,
      detail: SyncStatusStrings.rejectedDetail(record.errorCode),
      detailColor: AppColors.error,
      borderColor: AppColors.errorBorder,
    );
  }
}

/// Fila de un registro que llegó al backend en esta sesión.
class SyncSentRow extends StatelessWidget {
  /// Crea la fila.
  const SyncSentRow({required this.record, super.key});

  /// Registro enviado.
  final SyncSentRecord record;

  @override
  Widget build(BuildContext context) {
    return SyncRecordTile(
      icon: Icons.cloud_done_outlined,
      iconBackground: AppColors.backgroundPositiveContainer,
      iconColor: AppColors.checkIcon,
      title: SyncStatusStrings.operationKind(record.kind),
      time: record.sentAt,
      detail: SyncStatusStrings.sentState,
      detailColor: AppColors.positiveText,
    );
  }
}
