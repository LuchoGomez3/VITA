import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Card wrapper used for consistent feature surfaces.
class AppSurfaceCard extends StatelessWidget {
  /// Creates a surface card around [child].
  const AppSurfaceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  /// Content shown inside the card.
  final Widget child;

  /// Inner padding applied around [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
