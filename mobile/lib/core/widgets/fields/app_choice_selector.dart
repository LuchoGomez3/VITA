import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Opcion para un selector de chips.
class AppChoiceOption<T> {
  /// Crea una opcion con el valor interno y el texto visible indicados.
  const AppChoiceOption({
    required this.value,
    required this.label,
  });

  /// Valor que representa la opcion seleccionada.
  final T value;

  /// Texto visible para el usuario.
  final String label;
}

/// Selector reutilizable de una unica opcion.
class AppChoiceSelector<T> extends StatelessWidget {
  /// Crea un selector de opciones con seleccion unica.
  const AppChoiceSelector({
    required this.options,
    required this.onChanged,
    super.key,
    this.value,
    this.isSelected,
    this.title,
    this.titleStyle,
    this.selectedColor = AppColors.primary,
    this.selectedTextColor = AppColors.onPrimary,
    this.unSelectedColor = AppColors.onPrimary,
    this.unSelectedTextColor = AppColors.textPrimary,
  });

  /// Opciones disponibles para seleccionar.
  final List<AppChoiceOption<T>> options;

  /// Valor seleccionado actualmente. Se ignora si se provee [isSelected].
  final T? value;

  /// Callback opcional para determinar seleccion multiple.
  ///
  /// Si se provee, cada opcion se marca como seleccionada segun este callback
  /// en vez de compararse contra [value]. Permite reusar el mismo selector
  /// para casos de seleccion unica (default) o multiple.
  final bool Function(T value)? isSelected;

  /// Titulo opcional que se muestra sobre las opciones.
  final String? title;

  /// Estilo opcional para sobrescribir el titulo por defecto.
  final TextStyle? titleStyle;

  /// Callback que informa el valor seleccionado.
  final ValueChanged<T> onChanged;

  /// Color de fondo de la opcion seleccionada.
  final Color selectedColor;

  /// Color del texto de la opcion seleccionada.
  final Color selectedTextColor;

  /// Color de fondo de la opcion no seleccionada.
  final Color unSelectedColor;

  /// Color del texto de la opcion no seleccionada.
  final Color unSelectedTextColor;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle ?? AppTypography.secondaryEmphasis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(title!, style: effectiveTitleStyle),
          const SizedBox(height: AppSpacing.xxs),
        ],
        Wrap(
          spacing: AppSpacing.xxs,
          runSpacing: AppSpacing.xxs,
          children: options
              .map(
                (option) => _AppChoiceChip(
                  label: option.label,
                  isSelected: isSelected != null ? isSelected!(option.value) : option.value == value,
                  selectedColor: selectedColor,
                  selectedTextColor: selectedTextColor,
                  unSelectedColor: unSelectedColor,
                  unSelectedTextColor: unSelectedTextColor,
                  onTap: () => onChanged(option.value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AppChoiceChip extends StatelessWidget {
  const _AppChoiceChip({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.unSelectedColor,
    required this.unSelectedTextColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unSelectedColor;
  final Color unSelectedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? selectedColor : unSelectedColor;
    final textColor = isSelected ? selectedTextColor : unSelectedTextColor;
    final borderColor = isSelected ? selectedColor : AppColors.border;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: StadiumBorder(
            side: BorderSide(color: borderColor),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          style: AppTypography.mediumEmphasis.copyWith(color: textColor),
          child: Text(label),
        ),
      ),
    );
  }
}
