import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Fila de una sección de ajustes: icono, label, subtítulo opcional y
/// chevron opcional. Replica `SectionList` del diseño de referencia.
class SettingsRow extends StatelessWidget {
  /// Crea una fila de ajustes.
  const SettingsRow({
    required this.icon,
    required this.label,
    super.key,
    this.subtitle,
    this.subtitleColor,
    this.isNavigable = false,
    this.isPrimaryAction = false,
    this.onTap,
  });

  /// Icono representativo de la fila.
  final IconData icon;

  /// Etiqueta principal.
  final String label;

  /// Subtítulo opcional (detalle o valor mock).
  final String? subtitle;

  /// Color opcional del subtítulo (ej. verde cuando un dispositivo está
  /// conectado). Por defecto usa un tono neutro.
  final Color? subtitleColor;

  /// Si se muestra el chevron de navegación a la derecha.
  final bool isNavigable;

  /// Si la fila es una acción primaria (ej. "Vincular nuevo dispositivo").
  final bool isPrimaryAction;

  /// Acción disparada al tocar la fila.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isPrimaryAction ? AppColors.primary : AppColors.textSecondary;
    final labelColor = isPrimaryAction ? AppColors.primary : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isPrimaryAction ? AppColors.backgroundSecondary : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.mediumEmphasis.copyWith(color: labelColor)),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTypography.smallEmphasis.copyWith(color: subtitleColor ?? AppColors.textHint),
                    ),
                ],
              ),
            ),
            if (isNavigable) const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
