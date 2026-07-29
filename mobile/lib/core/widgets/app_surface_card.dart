import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Tarjeta reutilizable para agrupar contenido sobre una superficie elevada.
class AppSurfaceCard extends StatelessWidget {
  /// Crea una tarjeta con espaciado, elevacion y sombra configurables.
  const AppSurfaceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.elevation,
    this.shadowColor,
  });

  /// Contenido presentado dentro de la tarjeta.
  final Widget child;

  /// Espaciado entre el contenido y los bordes de la tarjeta.
  final EdgeInsetsGeometry padding;

  /// Altura visual opcional que determina la intensidad de la sombra.
  final double? elevation;

  /// Color opcional aplicado a la sombra proyectada por la tarjeta.
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shadowColor: shadowColor,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
