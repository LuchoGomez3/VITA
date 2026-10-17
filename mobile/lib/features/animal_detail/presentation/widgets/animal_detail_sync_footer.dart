import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Pie con el estado de sincronizacion offline y la ultima lectura.
class AnimalDetailSyncFooter extends StatelessWidget {
  /// Crea el pie de sincronizacion del detalle de animal.
  const AnimalDetailSyncFooter({
    required this.animalDetail,
    required this.onRetry,
    super.key,
  });

  /// Metadatos de sincronizacion del animal.
  final AnimalDetail animalDetail;

  /// Reintenta la sincronizacion cuando el alta fue rechazada.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (animalDetail.syncStatus == AnimalSyncStatus.rejected) {
      return _RejectedSyncError(
        errorCode: animalDetail.syncErrorCode,
        onRetry: onRetry,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            animalDetail.syncStatus.label,
            style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AnimalDetailStrings.lastReadingLabel,
              style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
            ),
            Text(
              DateDisplayFormatter.shortDate(animalDetail.updatedAt),
              style: AppTypography.smallEmphasis,
            ),
          ],
        ),
      ],
    );
  }
}

class _RejectedSyncError extends StatelessWidget {
  const _RejectedSyncError({
    required this.errorCode,
    required this.onRetry,
  });

  final String? errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                AnimalDetailStrings.rejectedSyncTitle,
                style: AppTypography.errorBody,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(_messageFor(errorCode), style: AppTypography.pageBodyTitle),
        const SizedBox(height: AppSpacing.md),
        AppErrorFilledButton(
          label: AnimalDetailStrings.retrySync,
          onPressed: onRetry,
        ),
      ],
    );
  }

  String _messageFor(String? errorCode) {
    // TODO(animal-sync): mapear cada codigo estable del backend a un mensaje y
    // una accion de correccion especificos cuando se acuerde ese contrato.
    return AnimalDetailStrings.rejectedSyncMessage;
  }
}

extension on AnimalSyncStatus {
  String get label => switch (this) {
    AnimalSyncStatus.pending => AnimalDetailStrings.pendingSyncStatus,
    AnimalSyncStatus.synchronized => AnimalDetailStrings.synchronizedSyncStatus,
    AnimalSyncStatus.rejected => AnimalDetailStrings.rejectedSyncStatus,
  };
}
