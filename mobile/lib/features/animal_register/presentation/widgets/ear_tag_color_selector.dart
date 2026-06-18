import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Opcion visual para seleccionar el color de una caravana.
class EarTagColorOption {
  /// Crea una opcion de color con su nombre visible.
  const EarTagColorOption({
    required this.name,
    required this.color,
  });

  /// Nombre visible del color.
  final String name;

  /// Color asociado a la opcion.
  final Color color;
}

/// Selector de colores de caravana distribuido en todo el ancho disponible.
class EarTagColorSelector extends StatelessWidget {
  /// Crea un selector de color de caravana.
  const EarTagColorSelector({
    required this.options,
    required this.selectedColor,
    required this.onChanged,
    super.key,
  });

  /// Opciones de color disponibles.
  final List<EarTagColorOption> options;

  /// Color seleccionado actualmente.
  final Color selectedColor;

  /// Callback que informa el nuevo color seleccionado.
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < options.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _EarTagColorItem(
              option: options[index],
              isSelected: options[index].color == selectedColor,
              onTap: () => onChanged(options[index].color),
            ),
          ),
        ],
      ],
    );
  }
}

class _EarTagColorItem extends StatelessWidget {
  const _EarTagColorItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final EarTagColorOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 52,
            width: double.infinity,
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
    );
  }
}
