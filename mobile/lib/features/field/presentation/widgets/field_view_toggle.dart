import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Toggle segmentado para alternar localmente entre el mapa y la lista.
class FieldViewToggle extends StatelessWidget {
  /// Crea el toggle marcando cuál de las dos vistas está activa.
  const FieldViewToggle({
    required this.isMapActive,
    required this.onMapSelected,
    required this.onListSelected,
    super.key,
  });

  /// Si la vista de mapa es la activa (en caso contrario, es la de lista).
  final bool isMapActive;

  /// Selecciona el lienzo esquemático.
  final VoidCallback onMapSelected;

  /// Selecciona el listado local.
  final VoidCallback onListSelected;

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
              onTap: onMapSelected,
            ),
            _segment(
              context: context,
              icon: Icons.list,
              label: FieldStrings.listTab,
              isActive: !isMapActive,
              onTap: onListSelected,
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
