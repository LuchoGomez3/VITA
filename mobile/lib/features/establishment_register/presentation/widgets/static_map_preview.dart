import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Vista decorativa de mapa, sin SDK real.
///
/// Réplica visual estática por decisión de producto (ver
/// .claude/specs/registrar-establecimiento.md): no hay paquete de mapas/GPS
/// en el proyecto todavía, así que esto es solo un fondo con degradé.
class StaticMapPreview extends StatelessWidget {
  /// Crea la vista decorativa de mapa.
  const StaticMapPreview({
    super.key,
    this.height = 200,
    this.child,
  });

  /// Alto de la vista previa.
  final double height;

  /// Contenido superpuesto al fondo decorativo (ej. un pin o un polígono).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundTertiary, AppColors.backgroundSecondary],
          ),
        ),
        child: child,
      ),
    );
  }
}
