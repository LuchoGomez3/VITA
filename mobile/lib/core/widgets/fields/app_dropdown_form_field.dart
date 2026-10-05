import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Opcion simple para reutilizar en el dropdown de la app.
class AppDropdownOption<T> {
  /// Crea una opcion simple para reutilizar en el dropdown de la app.
  const AppDropdownOption({
    /// El valor de la opcion.
    required this.value,

    /// El label de la opcion.
    required this.label,
  });

  /// El valor de la opcion.
  final T value;

  /// El label de la opcion.
  final String label;
}

/// Campo seleccionable reutilizable para formularios de la app.
///
/// Este widget envuelve `DropdownMenu` de Flutter y le aplica los estilos
/// default de la app para mantener consistencia visual. El menu queda anclado
/// debajo del campo, sin desplazarlo segun la opcion seleccionada.
///
/// TODO(forms): definir una estrategia comun de validaciones por tipo de campo.
/// Hoy se expone `validator` para que cada pantalla pueda consumir validadores
/// especificos desde `core/validators` o desde su feature.
class AppDropdownFormField<T> extends StatelessWidget {
  /// Crea un campo seleccionable reutilizable para formularios de la app.
  const AppDropdownFormField({
    required this.hintText,
    required this.options,
    super.key,
    this.initialValue,
    this.title,
    this.titleStyle,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.helperText,
    this.errorText,
    this.icon,
  });

  /// Hint del campo.
  final String hintText;

  /// Opciones del campo.
  final List<AppDropdownOption<T>> options;

  /// Valor inicial del campo.
  final T? initialValue;

  /// Titulo del campo.
  final String? title;

  /// Estilo del titulo del campo.
  final TextStyle? titleStyle;

  /// Validador del campo.
  final String? Function(T?)? validator;

  /// Callback para cuando el valor del campo cambia.
  final ValueChanged<T?>? onChanged;

  /// Indica si el campo esta habilitado.
  final bool enabled;

  /// Texto de ayuda del campo.
  final String? helperText;

  /// Mensaje de validacion mostrado debajo del campo.
  final String? errorText;

  /// Icono del campo.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle ?? AppTypography.secondaryEmphasis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: effectiveTitleStyle,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        FormField<T>(
          key: ValueKey(initialValue),
          initialValue: initialValue,
          validator: validator,
          builder: (field) => LayoutBuilder(
            builder: (context, constraints) => DropdownMenu<T>(
              initialSelection: field.value,
              enabled: enabled,
              width: constraints.maxWidth,
              menuHeight: 280,
              textStyle: AppTypography.formFieldValue,
              hintText: hintText,
              helperText: helperText,
              errorText: errorText ?? field.errorText,
              trailingIcon:
                  icon ??
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
              selectedTrailingIcon:
                  icon ??
                  const Icon(
                    Icons.keyboard_arrow_up,
                    color: AppColors.textSecondary,
                  ),
              dropdownMenuEntries: options
                  .map(
                    (option) => DropdownMenuEntry<T>(
                      value: option.value,
                      label: option.label,
                      labelWidget: Text(
                        option.label,
                        style: AppTypography.mediumEmphasis,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onSelected: enabled
                  ? (value) {
                      field.didChange(value);
                      onChanged?.call(value);
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
