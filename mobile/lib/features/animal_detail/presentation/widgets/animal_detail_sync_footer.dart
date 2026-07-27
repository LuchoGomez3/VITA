import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Pie con el estado de sincronizacion offline y la ultima lectura.
class AnimalDetailSyncFooter extends StatelessWidget {
  /// Crea el pie de sincronizacion del detalle de animal.
  const AnimalDetailSyncFooter({
    required this.animalDetail,
    super.key,
  });

  /// Metadatos de sincronizacion del animal.
  final AnimalDetail animalDetail;

  @override
  Widget build(BuildContext context) {
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

extension on AnimalSyncStatus {
  String get label => switch (this) {
    AnimalSyncStatus.pending => AnimalDetailStrings.pendingSyncStatus,
    AnimalSyncStatus.synchronized => AnimalDetailStrings.synchronizedSyncStatus,
    AnimalSyncStatus.rejected => AnimalDetailStrings.rejectedSyncStatus,
  };
}
