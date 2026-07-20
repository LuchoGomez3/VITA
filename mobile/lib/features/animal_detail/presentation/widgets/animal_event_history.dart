import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

/// Muestra cronologicamente los eventos de trazabilidad del animal.
class AnimalEventHistory extends StatelessWidget {
  /// Crea el historial a partir de los datos disponibles del animal.
  const AnimalEventHistory({
    required this.animalDetail,
    super.key,
  });

  /// Datos del animal usados para construir los eventos disponibles.
  final AnimalDetail animalDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AnimalDetailStrings.eventHistoryTitle,
          style: AppTypography.pageTitle,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTimeline(
          items: _buildTimelineItems(),
        ),
      ],
    );
  }

  List<AppTimelineItem> _buildTimelineItems() {
    final events = <_AnimalTimelineEvent>[
      _AnimalTimelineEvent(
        date: animalDetail.birthDate,
        item: AppTimelineItem(
          date: animalDetail.birthDate.displayDate,
          title: AnimalDetailStrings.birthEventTitle,
          description: AnimalDetailStrings.birthEventDescription,
          icon: Icons.add_circle_outline,
          iconColor: AppColors.primary,
        ),
      ),
      for (final weightRecord in animalDetail.weightHistory)
        _AnimalTimelineEvent(
          date: weightRecord.date,
          item: AppTimelineItem(
            date: weightRecord.date.displayDate,
            title: AnimalDetailStrings.weighingEventTitle,
            description: AnimalDetailStrings.weighingEventDescription(
              weight: weightRecord.weightKg.displayWeight,
              method: weightRecord.method.displayName,
            ),
            icon: Icons.monitor_weight_outlined,
            iconColor: AppColors.textSecondary,
          ),
        ),
    ];
    return (events..sort((first, second) => second.date.compareTo(first.date)))
        .map((event) => event.item)
        .toList(growable: false);
  }
}

class _AnimalTimelineEvent {
  const _AnimalTimelineEvent({
    required this.date,
    required this.item,
  });

  final DateTime date;
  final AppTimelineItem item;
}

extension on DateTime {
  String get displayDate {
    final day = this.day.toString().padLeft(2, '0');
    final month = this.month.toString().padLeft(2, '0');
    return '$day/$month/$year';
  }
}

extension on double {
  String get displayWeight => toStringAsFixed(truncateToDouble() == this ? 0 : 1);
}

extension on AnimalWeighingMethod {
  String get displayName => switch (this) {
    AnimalWeighingMethod.manual => AnimalDetailStrings.manualWeighingMethod,
    AnimalWeighingMethod.bluetoothScale => AnimalDetailStrings.bluetoothWeighingMethod,
    AnimalWeighingMethod.artificialIntelligence => AnimalDetailStrings.aiWeighingMethod,
  };
}
