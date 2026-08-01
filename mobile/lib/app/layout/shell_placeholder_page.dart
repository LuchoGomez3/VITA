import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

/// Pantalla temporal para una rama cuyo contenido aun no fue implementado.
class ShellPlaceholderPage extends StatelessWidget {
  /// Crea un placeholder minimo con el titulo de la futura seccion.
  const ShellPlaceholderPage({
    required this.title,
    super.key,
  });

  /// Nombre visible de la seccion pendiente.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: title),
      body: Center(
        child: Text(
          title,
          style: AppTypography.pageTitle,
        ),
      ),
    );
  }
}
