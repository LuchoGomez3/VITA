import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:go_router/go_router.dart';

/// Toggle segmentado flotante para alternar entre el mapa y la lista de
/// potreros. Cada opción es una ruta distinta, no un estado local.
class FieldViewToggle extends StatelessWidget {
  /// Crea el toggle marcando cuál de las dos vistas está activa.
  const FieldViewToggle({required this.isMapActive, super.key});

  /// Si la vista de mapa es la activa (en caso contrario, es la de lista).
  final bool isMapActive;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _segment(
              context: context,
              icon: Icons.map_outlined,
              label: FieldStrings.mapTab,
              isActive: isMapActive,
              onTap: () => context.go(AppRoutes.field),
            ),
            _segment(
              context: context,
              icon: Icons.list,
              label: FieldStrings.listTab,
              isActive: !isMapActive,
              onTap: () => context.go(AppRoutes.fieldList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.textPrimary : AppColors.onPrimary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                label,
                style: AppTypography.smallEmphasis.copyWith(
                  color: isActive ? AppColors.textPrimary : AppColors.onPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
