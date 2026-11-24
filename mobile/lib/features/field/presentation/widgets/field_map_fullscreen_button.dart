import 'package:flutter/material.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Control compartido para ampliar o contraer el lienzo.
class FieldMapFullscreenButton extends StatelessWidget {
  /// Construye el control con el estado de la pantalla que lo contiene.
  const FieldMapFullscreenButton({required this.expanded, required this.onPressed, super.key});

  /// Indica que el mapa ocupa toda la pantalla.
  final bool expanded;

  /// Cambia entre el mapa ampliado y la vista normal.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: expanded ? FieldStrings.collapseMap : FieldStrings.expandMap,
    onPressed: onPressed,
    icon: Icon(expanded ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded),
  );
}
