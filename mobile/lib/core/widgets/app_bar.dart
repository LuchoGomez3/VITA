import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App bar shared by feature pages.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an app header with optional custom back handling and actions.
  const AppHeader({
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

  @override
  /// Preferred app bar height.
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
