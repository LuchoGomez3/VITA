import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Header with the animal identifier and current location.
class AnimalDetailHeader extends StatelessWidget {
  /// Creates the animal detail header.
  const AnimalDetailHeader({
    required this.animalDetail,
    super.key,
  });

  /// Animal data shown in the header.
  final AnimalDetail animalDetail;

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
              Text(animalDetail.displayIdentifier, style: AppTypography.appBarTitle),
              Text(
                AnimalDetailStrings.animalIdLabel,
                style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
        _CurrentLocation(animalDetail: animalDetail),
      ],
    );
  }
}

class _CurrentLocation extends StatelessWidget {
  const _CurrentLocation({
    required this.animalDetail,
  });

  final AnimalDetail animalDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          animalDetail.lotName.isEmpty ? 'N/A' : animalDetail.lotName,
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

extension on AnimalDetail {
  String get displayIdentifier {
    if (visualTag.isNotEmpty) {
      return visualTag;
    }

    if (rfidTagNumber.isNotEmpty) {
      return rfidTagNumber;
    }

    return id;
  }
}
