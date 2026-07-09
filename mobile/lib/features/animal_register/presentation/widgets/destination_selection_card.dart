import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Destino mock disponible para asignar al animal.
class AnimalDestinationOption {
  /// Crea una opcion de destino.
  const AnimalDestinationOption({
    required this.id,
    required this.name,
    required this.details,
  });

  /// Identificador temporal del destino.
  final String id;

  /// Nombre visible del potrero.
  final String name;

  /// Informacion complementaria del destino.
  final String details;
}

/// Tarjeta reutilizable para seleccionar el destino del animal.
class DestinationSelectionCard extends StatelessWidget {
  /// Crea una tarjeta de destino seleccionable.
  const DestinationSelectionCard({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// Destino mostrado por la tarjeta.
  final AnimalDestinationOption destination;

  /// Indica si el destino esta seleccionado.
  final bool isSelected;

  /// Callback ejecutado al seleccionar la tarjeta.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundSecondary : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: AppColors.onPrimary,
                      size: 17,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: AppTypography.secondaryEmphasis.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    destination.details,
                    style: AppTypography.pageBodyTitle.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
