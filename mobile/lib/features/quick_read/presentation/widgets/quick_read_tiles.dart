import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Acción de la grilla "¿Qué querés hacer?" (`QuickAction` del diseño).
class QuickActionTile extends StatelessWidget {
  /// Crea la acción; sin [onTap] queda deshabilitada (`DisabledAction`).
  const QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    super.key,
    this.onTap,
    this.isWide = false,
  });

  /// Icono de la acción.
  final IconData icon;

  /// Nombre de la acción.
  final String label;

  /// Detalle (último peso, potrero, "Próximamente").
  final String subtitle;

  /// Acción; `null` la deshabilita.
  final VoidCallback? onTap;

  /// Acción principal ancha y llena (alta de animales).
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final filled = isWide && enabled;
    final foreground = filled ? AppColors.onPrimary : (enabled ? AppColors.textPrimary : AppColors.textHint);

    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: filled ? AppColors.primary : (enabled ? AppColors.surface : AppColors.background),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: filled ? BorderSide.none : BorderSide(color: enabled ? AppColors.border : AppColors.chipBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: isWide ? 64 : 88),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: filled
                          ? AppColors.onPrimary.withValues(alpha: 0.18)
                          : (enabled ? AppColors.backgroundSecondaryLight : AppColors.backgroundTertiary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: filled ? AppColors.onPrimary : (enabled ? AppColors.primary : AppColors.textHint),
                    ),
                  ),
                  SizedBox(width: isWide ? AppSpacing.sm : 0, height: isWide ? 0 : AppSpacing.xs),
                  Flexible(
                    fit: isWide ? FlexFit.tight : FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: foreground),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: filled ? AppColors.onPrimary.withValues(alpha: 0.85) : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isWide) Icon(Icons.chevron_right, color: foreground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grilla de dos columnas para las acciones.
class QuickActionGrid extends StatelessWidget {
  /// Crea la grilla.
  const QuickActionGrid({required this.children, super.key});

  /// Acciones, de a dos por fila.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xs),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Píldora con el estado del lector (`LectorStatus`).
class QuickReadStatusPill extends StatelessWidget {
  /// Crea la píldora.
  const QuickReadStatusPill({required this.label, super.key});

  /// Texto del estado.
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(color: AppColors.backgroundSecondaryLight, shape: StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: SizedBox(width: 8, height: 8),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.smallEmphasis.copyWith(color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
