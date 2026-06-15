import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Campo de fecha reutilizable que abre el selector nativo de Flutter.
class AppDateFormField extends StatelessWidget {
  /// Crea un campo de fecha integrado con `showDatePicker`.
  const AppDateFormField({
    required this.hintText,
    required this.onChanged,
    super.key,
    this.value,
    this.title,
    this.titleStyle,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.helperText,
  });

  /// Fecha seleccionada actualmente.
  final DateTime? value;

  /// Texto visible cuando aun no hay una fecha seleccionada.
  final String hintText;

  /// Titulo opcional que se muestra sobre el campo.
  final String? title;

  /// Estilo opcional para sobrescribir el titulo por defecto.
  final TextStyle? titleStyle;

  /// Validador integrado con el `Form` contenedor.
  final String? Function(DateTime?)? validator;

  /// Callback que informa la nueva fecha seleccionada.
  final ValueChanged<DateTime> onChanged;

  /// Primera fecha permitida por el selector.
  final DateTime? firstDate;

  /// Ultima fecha permitida por el selector.
  final DateTime? lastDate;

  /// Indica si el campo permite abrir el selector.
  final bool enabled;

  /// Texto auxiliar opcional que se muestra debajo del campo.
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle ?? AppTypography.formFieldLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(title!, style: effectiveTitleStyle),
          const SizedBox(height: AppSpacing.xs),
        ],
        FormField<DateTime>(
          key: ValueKey(value),
          initialValue: value,
          validator: validator,
          builder: (field) {
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: enabled ? () => _openDatePicker(context, field) : null,
              child: InputDecorator(
                isEmpty: field.value == null,
                decoration: InputDecoration(
                  helperText: helperText,
                  errorText: field.errorText,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textPrimary,
                  ),
                ),
                child: Text(
                  field.value == null ? hintText : _formatDate(field.value!),
                  style: field.value == null
                      ? AppTypography.formFieldHint
                      : AppTypography.formFieldValue.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _openDatePicker(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final effectiveFirstDate = firstDate ?? DateTime(today.year - 30);
    final effectiveLastDate = lastDate ?? today;
    final initialDate = field.value ?? effectiveLastDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
    );

    if (selectedDate == null) {
      return;
    }

    field.didChange(selectedDate);
    onChanged(selectedDate);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day / $month / ${date.year}';
  }
}
