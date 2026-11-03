import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';

/// Banner con el resumen de la cola: vacía, esperando, enviando o sin señal.
class SyncProgressBanner extends StatelessWidget {
  /// Crea el banner.
  const SyncProgressBanner({
    required this.pendingCount,
    required this.isSending,
    required this.isOnline,
    super.key,
  });

  /// Operaciones que faltan llegar al servidor.
  final int pendingCount;

  /// `true` si alguna operación se está enviando ahora.
  final bool isSending;

  /// Conectividad del dispositivo; `null` si todavía no se conoce.
  final bool? isOnline;

  @override
  Widget build(BuildContext context) {
    final offline = isOnline == false;
    final (icon, background, foreground, title, detail) = switch ((pendingCount, offline, isSending)) {
      (0, _, _) => (
        Icons.cloud_done_outlined,
        AppColors.backgroundSecondary,
        AppColors.primary,
        SyncStatusStrings.emptyBannerTitle,
        SyncStatusStrings.emptyBannerDetail,
      ),
      (_, true, _) => (
        Icons.cloud_off_outlined,
        AppColors.syncPendingContainer,
        AppColors.syncPending,
        SyncStatusStrings.offlineBannerTitle(pendingCount),
        SyncStatusStrings.offlineBannerDetail,
      ),
      (_, false, true) => (
        Icons.sync,
        AppColors.backgroundSecondary,
        AppColors.primary,
        SyncStatusStrings.sendingBannerTitle(pendingCount),
        SyncStatusStrings.onlineBannerDetail,
      ),
      (_, false, false) => (
        Icons.cloud_upload_outlined,
        AppColors.backgroundSecondary,
        AppColors.primary,
        SyncStatusStrings.waitingBannerTitle(pendingCount),
        SyncStatusStrings.onlineBannerDetail,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.mediumEmphasis.copyWith(color: foreground)),
                  Text(detail, style: AppTypography.smallEmphasis.copyWith(color: foreground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
