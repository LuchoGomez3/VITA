import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Shared section header with title and subtitle.
class AppSectionHeader extends StatelessWidget {
  /// Creates a section header.
  const AppSectionHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  /// Main section title.
  final String title;

  /// Supporting section text.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
