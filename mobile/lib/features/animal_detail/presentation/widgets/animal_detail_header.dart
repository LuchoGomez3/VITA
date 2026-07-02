import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Header with the animal identifier and current location.
class AnimalDetailHeader extends StatelessWidget {
  /// Creates the animal detail header.
  const AnimalDetailHeader({
    required this.animalId,
    super.key,
  });

  /// Animal identifier shown as the main title.
  final String animalId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(dimension: 48),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(animalId, style: AppTypography.appBarTitle),
              Text(
                AnimalDetailStrings.animalIdLabel,
                style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
        const _CurrentLocation(),
      ],
    );
  }
}

class _CurrentLocation extends StatelessWidget {
  const _CurrentLocation();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          AnimalDetailStrings.currentLot,
          style: AppTypography.mediumEmphasis,
        ),
        Text(
          AnimalDetailStrings.currentLocationLabel,
          style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}
