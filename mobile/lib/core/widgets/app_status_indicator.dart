import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Indicador circular reutilizable para procesos y resultados de pantalla.
class AppStatusIndicator extends StatelessWidget {
  /// Crea un indicador con icono, color y progreso configurables.
  const AppStatusIndicator({
    required this.icon,
    required this.color,
    required this.isLoading,
    super.key,
  });

  /// Icono representativo del proceso o resultado.
  final IconData icon;

  /// Color aplicado al progreso, fondo suave e icono.
  final Color color;

  /// Indica si el trazo debe animarse de manera indefinida.
  final bool isLoading;

  static const _dimension = 86.0;
  static const _innerDimension = 68.0;
  static const _iconSize = 34.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _dimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: SizedBox.square(
              key: ValueKey(isLoading),
              dimension: _dimension,
              child: CircularProgressIndicator(
                value: isLoading ? null : 1,
                strokeWidth: 4,
                backgroundColor: AppColors.backgroundTertiary,
                color: color,
              ),
            ),
          ),
          Container(
            width: _innerDimension,
            height: _innerDimension,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                icon,
                key: ValueKey(icon),
                color: color,
                size: _iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
