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
/// Cada formulario puede proveer su validación mediante [validator].
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
    this.animateMenu = false,
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

  /// Abre el menú anclado con la transición nativa de Material.
  final bool animateMenu;

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
          // `expandedInsets` ocupa todo el ancho disponible sin LayoutBuilder:
          // un LayoutBuilder rompe el layout dentro de un AlertDialog, que mide
          // el contenido con anchos intrínsecos (la pantalla quedaba en negro).
          builder: (field) => animateMenu
              ? _AnimatedDropdownMenu<T>(input: this, field: field)
              : DropdownMenu<T>(
                  initialSelection: field.value,
                  enabled: enabled,
                  expandedInsets: EdgeInsets.zero,
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
      ],
    );
  }
}

class _AnimatedDropdownMenu<T> extends StatelessWidget {
  const _AnimatedDropdownMenu({required this.input, required this.field});

  final AppDropdownFormField<T> input;
  final FormFieldState<T> field;

  @override
  Widget build(BuildContext context) {
    final selected = input.options.where((option) => option.value == field.value).firstOrNull;
    final enabled = input.enabled && input.options.isNotEmpty;
    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        animated: true,
        alignmentOffset: const Offset(0, AppSpacing.xxs),
        crossAxisUnconstrained: false,
        style: MenuStyle(
          alignment: AlignmentDirectional.bottomStart,
          minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 0)),
          maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 280)),
          backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm))),
        ),
        menuChildren: [
          for (final option in input.options)
            MenuItemButton(
              trailingIcon: option == selected ? const Icon(Icons.check, size: 18, color: AppColors.primary) : null,
              onPressed: () {
                field.didChange(option.value);
                input.onChanged?.call(option.value);
              },
              child: Text(option.label, style: AppTypography.formFieldValue),
            ),
        ],
        builder: (context, menu, child) => InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: enabled ? () => menu.isOpen ? menu.close() : menu.open() : null,
          child: InputDecorator(
            decoration: InputDecoration(
              enabled: enabled,
              helperText: input.helperText,
              errorText: input.errorText ?? field.errorText,
              suffixIcon: input.icon ?? Icon(menu.isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            ),
            child: Text(
              selected?.label ?? input.hintText,
              style: selected == null ? AppTypography.formFieldHint : AppTypography.formFieldValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
