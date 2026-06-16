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

/// Selector reutilizable de una unica opcion basado en `ChoiceChip`.
class AppChoiceSelector<T> extends StatelessWidget {
  /// Crea un selector de opciones con seleccion unica.
  const AppChoiceSelector({
    required this.options,
    required this.onChanged,
    super.key,
    this.value,
    this.title,
    this.titleStyle,
    this.selectedColor = AppColors.primary,
    this.selectedTextColor = AppColors.onPrimary,
    this.unSelectedColor = AppColors.surface,
    this.unSelectedTextColor = AppColors.textPrimary,
  });

  /// Opciones disponibles para seleccionar.
  final List<AppChoiceOption<T>> options;

  /// Valor seleccionado actualmente.
  final T? value;

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
    final effectiveTitleStyle = titleStyle ?? AppTypography.formFieldLabel;

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
                (option) => ChoiceChip(
                  label: Text(option.label),
                  selected: option.value == value,
                  showCheckmark: false,
                  selectedColor: selectedColor,
                  backgroundColor: unSelectedColor,
                  side: const BorderSide(color: AppColors.border),
                  shape: const StadiumBorder(),
                  labelStyle: AppTypography.mediumEmphasis.copyWith(
                    color: option.value == value ? selectedTextColor : unSelectedTextColor,
                  ),
                  onSelected: (_) => onChanged(option.value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
