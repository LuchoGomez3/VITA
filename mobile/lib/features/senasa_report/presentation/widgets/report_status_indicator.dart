import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Visual status indicator used by SENASA loading and result pages.
class ReportStatusIndicator extends StatelessWidget {
  /// Creates an animated loading indicator.
  const ReportStatusIndicator.loading({super.key})
    : icon = Icons.description_outlined,
      color = AppColors.primary,
      isLoading = true;

  /// Creates a static success indicator.
  const ReportStatusIndicator.success({super.key}) : icon = Icons.check, color = AppColors.primary, isLoading = false;

  /// Creates a static error indicator.
  const ReportStatusIndicator.error({super.key})
    : icon = Icons.priority_high,
      color = AppColors.error,
      isLoading = false;

  /// Icon shown at the center of the indicator.
  final IconData icon;

  /// Color used by the indicator stroke and icon.
  final Color color;

  /// Whether the circular stroke should animate indefinitely.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 86,
            child: CircularProgressIndicator(
              value: isLoading ? null : 1,
              strokeWidth: 4,
              backgroundColor: AppColors.backgroundTertiary,
              color: color,
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 34),
          ),
        ],
      ),
    );
  }
}
