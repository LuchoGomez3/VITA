import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed; // <- REVISÁ QUE ESTA LÍNEA ESTÉ ACÁ
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.onBackPressed, // <- Y QUE ESTA TAMBIÉN ESTÉ DENTRO DEL CONSTRUCTOR
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        // Si le pasamos una función la ejecuta, si no, hace el pop normal
        onPressed: onBackPressed ?? () => context.pop(),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}