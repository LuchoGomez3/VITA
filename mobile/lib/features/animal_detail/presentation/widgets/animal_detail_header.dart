import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Encabezado con el identificador del animal y su ubicacion actual.
class AnimalDetailHeader extends StatelessWidget {
  /// Crea el encabezado del detalle de animal.
  const AnimalDetailHeader({
    required this.animalDetail,
    super.key,
  });

  /// Datos del animal mostrados en el encabezado.
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
          animalDetail.lotName.isEmpty ? AnimalDetailStrings.noDataValue : animalDetail.lotName,
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
