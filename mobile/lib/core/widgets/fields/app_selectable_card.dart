import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Tarjeta seleccionable reutilizable con ícono, título y subtítulo.
/// Ideal para opciones excluyentes (comportamiento de Radio Button).
class AppSelectableCard<T> extends StatelessWidget {
  /// Valor que representa esta opción.
  final T value;

  /// El valor actualmente seleccionado en el grupo.
  final T? groupValue;

  /// Título principal de la tarjeta.
  final String title;

  /// Descripción secundaria de la tarjeta.
  final String subtitle;

  /// Ícono descriptivo.
  final IconData icon;

  /// Callback que se dispara al seleccionar la tarjeta.
  final ValueChanged<T> onChanged;

  const AppSelectableCard({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // La tarjeta sabe si está seleccionada comparando su valor con el del grupo
    final bool isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.04) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border, // O AppColors.chipBorder
            width: isSelected ? AppBorders.bold : AppBorders.normal,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isSelected ? AppColors.primary : AppColors.textSecondary, 
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.formFieldValue.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle, 
                    style: AppTypography.smallEmphasis.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            // Pseudo-Radio Button dinámico
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border, 
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, 
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}