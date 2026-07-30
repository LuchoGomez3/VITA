import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App bar shared by feature pages.
class AppBarHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an app header with optional custom back handling and actions.
  const AppBarHeader({
    required this.title,
    super.key,
    this.onBackPressed,
    this.actions,
  });

  /// Title shown in the app bar.
  final String title;

  /// Custom back action. Defaults to [GoRouter.pop].
  final VoidCallback? onBackPressed;

  /// Widgets shown at the end of the app bar.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => context.pop(),
      ),
      actions: actions,
    );
  }

  /// Preferred app bar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
