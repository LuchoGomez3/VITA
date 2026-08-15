import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Tono semántico de un [AppStatusChip].
enum AppStatusChipTone {
  /// Estado neutro, sin connotación positiva ni negativa.
  neutral,

  /// Estado positivo o confirmado.
  success,

  /// Estado de alerta o pendiente de atención.
  warn,
}

/// Pill compacta para mostrar un estado o conteo corto, con punto opcional.
class AppStatusChip extends StatelessWidget {
  /// Crea una chip de estado.
  const AppStatusChip({
    required this.label,
    super.key,
    this.tone = AppStatusChipTone.neutral,
    this.showDot = false,
  });

  /// Texto mostrado dentro de la chip.
  final String label;

  /// Tono semántico que determina los colores.
  final AppStatusChipTone tone;

  /// Si se muestra un punto de color antes del texto.
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      AppStatusChipTone.neutral => (AppColors.backgroundTertiary, AppColors.textSecondary),
      AppStatusChipTone.success => (AppColors.backgroundSecondary, AppColors.primary),
      AppStatusChipTone.warn => (AppColors.warning.withValues(alpha: 0.15), AppColors.warning),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              DecoratedBox(
                decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
                child: const SizedBox(width: 6, height: 6),
              ),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Text(label, style: AppTypography.smallEmphasis.copyWith(color: foreground)),
          ],
        ),
      ),
    );
  }
}
