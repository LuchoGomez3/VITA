import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

/// Footer with offline sync and last reading metadata.
class AnimalDetailSyncFooter extends StatelessWidget {
  /// Creates the animal detail sync footer.
  const AnimalDetailSyncFooter({
    required this.animalDetail,
    super.key,
  });

  /// Animal sync metadata.
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
              animalDetail.updatedAt.displayDate,
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

extension on DateTime {
  String get displayDate {
    final day = this.day.toString().padLeft(2, '0');
    final month = this.month.toString().padLeft(2, '0');
    return '$day/$month/$year';
  }
}
