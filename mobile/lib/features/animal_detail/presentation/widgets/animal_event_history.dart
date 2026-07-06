import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Timeline with the animal traceability events.
class AnimalEventHistory extends StatelessWidget {
  /// Creates the animal event history section.
  const AnimalEventHistory({
    required this.animalDetail,
    super.key,
  });

  /// Animal data used to build currently available events.
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
          items: [
            AppTimelineItem(
              date: animalDetail.birthDate.displayDate,
              title: AnimalDetailStrings.birthEventTitle,
              description: AnimalDetailStrings.birthEventDescription,
              icon: Icons.add_circle_outline,
              iconColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}

extension on DateTime {
  String get displayDate {
    final day = this.day.toString().padLeft(2, '0');
    final month = this.month.toString().padLeft(2, '0');
    return '$day/$month/$year';
  }
}
