import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Opcion para un selector segmentado.
class AppSegmentedOption<T> {
  /// Crea una opcion para un selector segmentado.
  const AppSegmentedOption({
    required this.value,
    required this.label,
  });

  /// Valor que representa la opcion.
  final T value;

  /// Texto visible dentro del segmento.
  final String label;
}

/// Selector segmentado reutilizable basado en `SegmentedButton` de Flutter.
class AppSegmentedFormField<T> extends StatelessWidget {
  /// Crea un selector segmentado integrado con formularios.
  const AppSegmentedFormField({
    required this.options,
    required this.onChanged,
    super.key,
    this.value,
    this.title,
    this.titleStyle,
    this.validator,
    this.enabled = true,
  });

  /// Opciones que componen el selector.
  final List<AppSegmentedOption<T>> options;

  /// Valor seleccionado actualmente.
  final T? value;

  /// Titulo opcional que se muestra sobre el selector.
  final String? title;

  /// Estilo opcional para sobrescribir el titulo por defecto.
  final TextStyle? titleStyle;

  /// Validador integrado con el `Form` contenedor.
  final String? Function(T?)? validator;

  /// Callback que informa el valor seleccionado.
  final ValueChanged<T> onChanged;

  /// Indica si el usuario puede cambiar la seleccion.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle ?? AppTypography.secondaryEmphasis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(title!, style: effectiveTitleStyle),
          const SizedBox(height: AppSpacing.xs),
        ],
        FormField<T>(
          key: ValueKey(value),
          initialValue: value,
          validator: validator,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<T>(
                    expandedInsets: EdgeInsets.zero,
                    segments: options
                        .map(
                          (option) => ButtonSegment<T>(
                            value: option.value,
                            label: Text(option.label),
                          ),
                        )
                        .toList(),
                    selected: field.value == null ? <T>{} : <T>{field.value as T},
                    emptySelectionAllowed: true,
                    showSelectedIcon: false,
                    onSelectionChanged: enabled
                        ? (selection) {
                            if (selection.isEmpty) {
                              return;
                            }

                            final selectedValue = selection.first;
                            field.didChange(selectedValue);
                            onChanged(selectedValue);
                          }
                        : null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.background,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) =>
                            states.contains(WidgetState.selected) ? AppColors.onPrimary : AppColors.textSecondary,
                      ),
                      textStyle: WidgetStateProperty.all(
                        AppTypography.secondaryEmphasis,
                      ),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: AppColors.border),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                    ),
                  ),
                ),
                if (field.errorText != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
