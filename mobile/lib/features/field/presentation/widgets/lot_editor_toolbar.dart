import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Acciones geométricas compactas del editor de lote.
class LotEditorToolbar extends StatelessWidget {
  /// Crea la barra con acciones habilitadas según el estado actual.
  const LotEditorToolbar({
    required this.canUndo,
    required this.canRedo,
    required this.canDelete,
    required this.canClear,
    required this.onUndo,
    required this.onRedo,
    required this.onDelete,
    required this.onClear,
    super.key,
  });

  /// Indica si existe un cambio para deshacer.
  final bool canUndo;

  /// Indica si existe un cambio para rehacer.
  final bool canRedo;

  /// Indica si hay un vértice seleccionado para eliminar.
  final bool canDelete;

  /// Indica si el perímetro puede limpiarse.
  final bool canClear;

  /// Deshace el último cambio geométrico.
  final VoidCallback onUndo;

  /// Rehace el último cambio geométrico.
  final VoidCallback onRedo;

  /// Elimina el vértice seleccionado.
  final VoidCallback onDelete;

  /// Elimina todos los vértices.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _action(
          icon: Icons.undo,
          tooltip: FieldStrings.undoTooltip,
          onPressed: canUndo ? onUndo : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        _action(
          icon: Icons.redo,
          tooltip: FieldStrings.redoTooltip,
          onPressed: canRedo ? onRedo : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        _action(
          icon: Icons.delete_outline,
          tooltip: FieldStrings.deleteVertexTooltip,
          onPressed: canDelete ? onDelete : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        _action(
          icon: Icons.delete_sweep_outlined,
          tooltip: FieldStrings.clearBoundaryTooltip,
          onPressed: canClear ? onClear : null,
        ),
      ],
    );
  }

  Widget _action({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}
