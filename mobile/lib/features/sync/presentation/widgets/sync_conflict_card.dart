import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/sync/presentation/mock/sync_status_mock.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';

/// Card de un conflicto last-write-wins, con los 2 valores en pugna y las
/// acciones de resolución.
///
/// Los botones son mock: no invocan al motor de sync real todavía (ver
/// "Explícitamente fuera de alcance" en `.claude/specs/sincronizacion.md`).
class SyncConflictCard extends StatelessWidget {
  /// Crea la card a partir de un conflicto mock.
  const SyncConflictCard({
    required this.conflict,
    required this.onKeepServer,
    required this.onApplyMine,
    super.key,
  });

  /// Conflicto representado.
  final SyncConflictMock conflict;

  /// Acción disparada al elegir mantener el valor del servidor.
  final VoidCallback onKeepServer;

  /// Acción disparada al elegir aplicar el valor propio.
  final VoidCallback onApplyMine;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.errorBorder),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(conflict.title, style: AppTypography.mediumEmphasis),
                ),
                const AppStatusChip(
                  label: SyncStatusStrings.lastWriteWinsChipLabel,
                  tone: AppStatusChipTone.danger,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              conflict.description,
              style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ConflictValueBlock(
              label: SyncStatusStrings.localChangeLabel(conflict.localTimestampLabel),
              value: conflict.localValue,
              background: AppColors.backgroundTertiary,
              foreground: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xxs),
            _ConflictValueBlock(
              label: SyncStatusStrings.serverChangeLabel(conflict.serverAuthorTimestampLabel),
              value: conflict.serverValue,
              background: AppColors.backgroundSecondary,
              foreground: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    label: SyncStatusStrings.keepServerButtonLabel,
                    onPressed: onKeepServer,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppFilledButton(
                    label: SyncStatusStrings.applyMineButtonLabel,
                    onPressed: onApplyMine,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictValueBlock extends StatelessWidget {
  const _ConflictValueBlock({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.smallEmphasis.copyWith(color: foreground),
            ),
            Text(value, style: AppTypography.mediumEmphasis.copyWith(color: foreground)),
          ],
        ),
      ),
    );
  }
}
