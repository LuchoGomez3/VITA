import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Immutable data used by [AppTimeline].
class AppTimelineItem {
  /// Creates a timeline item.
  const AppTimelineItem({
    required this.date,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  /// Date or short time label shown on the left.
  final String date;

  /// Main event title.
  final String title;

  /// Supporting event description.
  final String description;

  /// Icon that represents the event type.
  final IconData icon;

  /// Accent color for the event icon.
  final Color iconColor;
}

/// Vertical timeline for chronological event lists.
class AppTimeline extends StatelessWidget {
  /// Creates a timeline from [items].
  const AppTimeline({
    required this.items,
    super.key,
  });

  /// Items rendered in display order.
  final List<AppTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _TimelineTile(
          item: items[index],
          isLast: index == items.length - 1,
        );
      },
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.item,
    required this.isLast,
  });

  final AppTimelineItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              item.date,
              style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
            ),
          ),
          Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(item.icon, size: 18, color: item.iconColor),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTypography.mediumEmphasis),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.description,
                    style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
