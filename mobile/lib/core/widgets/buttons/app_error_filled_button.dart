import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Boton filled para acciones asociadas a errores o alertas.
class AppErrorFilledButton extends StatelessWidget {
  /// Crea un boton compacto con color de error.
  const AppErrorFilledButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// El texto del boton.
  final String label;

  /// La funcion que se ejecuta cuando se presiona el boton.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.errorButton,
        ),
      ),
    );
  }
}
