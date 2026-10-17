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

  /// Lado de la caja del icono (32 en el diseño).
  static const _iconBoxSize = 32.0;

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
    final detail = subtitle;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // En el diseño la acción primaria tiene la caja verde llena.
            Container(
              width: _iconBoxSize,
              height: _iconBoxSize,
              decoration: BoxDecoration(
                color: isPrimaryAction ? AppColors.primary : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isPrimaryAction ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.mediumEmphasis.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isPrimaryAction ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      style: AppTypography.smallEmphasis.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor ?? AppColors.textHint,
                      ),
                    ),
                ],
              ),
            ),
            if (isNavigable) const Icon(Icons.chevron_right, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
