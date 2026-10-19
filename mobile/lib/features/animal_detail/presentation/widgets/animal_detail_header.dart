import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Encabezado con el identificador del animal y su ubicacion actual.
class AnimalDetailHeader extends StatelessWidget {
  /// Crea el encabezado del detalle de animal.
  const AnimalDetailHeader({
    required this.animalDetail,
    super.key,
    this.showAvatar = true,
  });

  /// Datos del animal mostrados en el encabezado.
  final AnimalDetail animalDetail;

  /// Conserva el círculo original si la foto grande no pudo mostrarse.
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showAvatar) ...[
          const DecoratedBox(
            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: SizedBox.square(dimension: 48),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                animalDetail.displayIdentifier,
                style: AppTypography.appBarTitle,
              ),
              Text(
                AnimalDetailStrings.animalIdLabel,
                style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
              ),
              const SizedBox(height: AppSpacing.xxs),
              AppStatusChip(
                label: animalDetail.productiveStatus.label,
                tone: animalDetail.productiveStatus.tone,
                showDot: true,
              ),
            ],
          ),
        ),
        _CurrentLocation(animalDetail: animalDetail),
      ],
    );
  }
}

extension on AnimalProductiveStatus {
  String get label => switch (this) {
    AnimalProductiveStatus.active => AnimalDetailStrings.productiveStatusActive,
    AnimalProductiveStatus.sold => AnimalDetailStrings.productiveStatusSold,
    AnimalProductiveStatus.dead => AnimalDetailStrings.productiveStatusDead,
    AnimalProductiveStatus.removed => AnimalDetailStrings.productiveStatusRemoved,
    AnimalProductiveStatus.unknown => AnimalDetailStrings.productiveStatusUnknown,
  };

  AppStatusChipTone get tone => switch (this) {
    AnimalProductiveStatus.active => AppStatusChipTone.success,
    AnimalProductiveStatus.sold || AnimalProductiveStatus.removed => AppStatusChipTone.warning,
    AnimalProductiveStatus.dead => AppStatusChipTone.error,
    AnimalProductiveStatus.unknown => AppStatusChipTone.neutral,
  };
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
