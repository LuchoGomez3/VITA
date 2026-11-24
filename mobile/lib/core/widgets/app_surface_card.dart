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
    this.color,
    this.clipBehavior = Clip.none,
    this.onTap,
  });

  /// Contenido presentado dentro de la tarjeta.
  final Widget child;

  /// Espaciado entre el contenido y los bordes de la tarjeta.
  final EdgeInsetsGeometry padding;

  /// Altura visual opcional que determina la intensidad de la sombra.
  final double? elevation;

  /// Color opcional aplicado a la sombra proyectada por la tarjeta.
  final Color? shadowColor;

  /// Color de fondo opcional de la superficie.
  final Color? color;

  /// Recorte aplicado al contenido usando la forma de la tarjeta.
  final Clip clipBehavior;

  /// Accion opcional que vuelve interactiva toda la superficie.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: child,
    );
    return Card(
      elevation: elevation,
      shadowColor: shadowColor,
      color: color,
      clipBehavior: onTap == null || clipBehavior != Clip.none ? clipBehavior : Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
