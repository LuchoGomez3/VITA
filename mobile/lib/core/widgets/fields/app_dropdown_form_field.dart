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
/// Este widget envuelve `DropdownButtonFormField` de Flutter y le aplica los
/// estilos default de la app para mantener consistencia visual.
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

  /// Icono del campo.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle ?? AppTypography.formFieldLabel;

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
        DropdownButtonFormField<T>(
          initialValue: initialValue,
          validator: validator,
          onChanged: enabled ? onChanged : null,
          isExpanded: true,
          icon:
              icon ??
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          style: AppTypography.formFieldValue,
          hint: Text(
            hintText,
            style: AppTypography.formFieldHint,
          ),
          decoration: InputDecoration(
            helperText: helperText,
          ),
          items: options
              .map(
                (option) => DropdownMenuItem<T>(
                  value: option.value,
                  child: Text(
                    option.label,
                    style: AppTypography.formFieldValue,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
