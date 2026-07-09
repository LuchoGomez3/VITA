import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Compact label/value block for read-only detail surfaces.
class AppInfoCell extends StatelessWidget {
  /// Creates a read-only info cell.
  const AppInfoCell({
    required this.label,
    required this.value,
    super.key,
    this.isHighlighted = false,
  });

  /// Secondary label that describes the value.
  final String label;

  /// Main value displayed by the cell.
  final String value;

  /// Whether the value should be visually highlighted.
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
        ),
        const SizedBox(height: AppSpacing.xxs),
        if (isHighlighted)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              child: Text(value, style: AppTypography.mediumEmphasis),
            ),
          )
        else
          Text(value, style: AppTypography.mediumEmphasis),
      ],
    );
  }
}
