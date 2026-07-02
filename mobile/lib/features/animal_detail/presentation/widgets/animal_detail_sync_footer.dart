import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Footer with offline sync and last reading metadata.
class AnimalDetailSyncFooter extends StatelessWidget {
  /// Creates the animal detail sync footer.
  const AnimalDetailSyncFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            AnimalDetailStrings.pendingSyncEvents,
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
            const Text(
              AnimalDetailStrings.lastReadingDate,
              style: AppTypography.smallEmphasis,
            ),
          ],
        ),
      ],
    );
  }
}
