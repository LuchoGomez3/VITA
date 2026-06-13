import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Opcion visual para seleccionar el color de una caravana.
class EarTagColorOption {
  /// Crea una nueva opcion de color de caravana.
  const EarTagColorOption({
    required this.name,
    required this.isSelected,
    required this.color,
  });

  /// Nombre de la opcion de color de caravana.
  final String name;
  /// Indica si la opcion de color de caravana esta seleccionada.
  final bool isSelected;
  /// Color de la opcion de color de caravana.
  final Color color;
}

/// Selector reutilizable de colores de caravana dentro del flujo de registro.
class EarTagColorSelector extends StatelessWidget {
  /// Crea un nuevo selector de colores de caravana.
  const EarTagColorSelector({
    required this.options,
    required this.isSelected,
    required this.onChanged,
    super.key,
  });

  /// Opciones de color de caravana.
  final List<EarTagColorOption> options;
  /// Indica si la opcion de color de caravana esta seleccionada.
  final bool isSelected;
  /// Callback para cuando se selecciona un color de caravana.
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options
          .map(
            (option) => _EarTagColorItem(
              option: option,
              isSelected: false,
              onTap: () => onChanged(option.color),
            ),
          )
          .toList(),
    );
  }
}

class _EarTagColorItem extends StatelessWidget {
  /// Crea un nuevo item de color de caravana.
  const _EarTagColorItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  /// Opcion de color de caravana.
  final EarTagColorOption option;
  /// Indica si la opcion de color de caravana esta seleccionada.
  final bool isSelected;
  /// Callback para cuando se selecciona un color de caravana.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 52,
              decoration: BoxDecoration(
                color: option.color,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              option.name,
              style: AppTypography.smallEmphasis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
