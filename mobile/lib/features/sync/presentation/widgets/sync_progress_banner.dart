import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';

/// Banner de progreso de la sincronización en curso.
class SyncProgressBanner extends StatelessWidget {
  /// Crea el banner con el progreso y la conexión mock.
  const SyncProgressBanner({
    required this.done,
    required this.total,
    required this.connectionLabel,
    super.key,
  });

  /// Cantidad de registros ya procesados.
  final int done;

  /// Cantidad total de registros a sincronizar.
  final int total;

  /// Descripción mock de la conexión activa.
  final String connectionLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.sync, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SyncStatusStrings.progressBannerTitle(total),
                    style: AppTypography.mediumEmphasis.copyWith(color: AppColors.primary),
                  ),
                  Text(
                    connectionLabel,
                    style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Text(
              SyncStatusStrings.progressCounter(done, total),
              style: AppTypography.monoValueEmphasis.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
