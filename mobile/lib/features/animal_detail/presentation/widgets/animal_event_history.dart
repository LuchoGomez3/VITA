import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Timeline with the animal traceability events.
class AnimalEventHistory extends StatelessWidget {
  /// Creates the animal event history section.
  const AnimalEventHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AnimalDetailStrings.eventHistoryTitle,
          style: AppTypography.pageTitle,
        ),
        SizedBox(height: AppSpacing.md),
        AppTimeline(items: AnimalDetailStrings.eventHistoryItems),
      ],
    );
  }
}
