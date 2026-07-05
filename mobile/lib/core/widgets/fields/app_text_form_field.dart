import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Campo de texto reutilizable para formularios de la app.
///
/// Muestra un titulo opcional arriba del input y reutiliza los estilos base de
/// la paleta/tipografia oficial.
///
/// Hoy se expone `validator` para que cada pantalla pueda consumir validadores
/// especificos desde `core/validators` o desde su feature.
// TODO(agusf): definir una estrategia comun de validaciones por tipo de campo.
class AppTextFormField extends StatelessWidget {
  /// Crea un campo de texto reutilizable para formularios de la app.
  const AppTextFormField({
    required this.hintText,
    super.key,
    this.controller,
    this.title,
    this.titleStyle,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
  });

  /// El controlador del campo de texto.
  final TextEditingController? controller;

  /// El texto de ayuda para el campo.
  final String hintText;

  /// El titulo del campo.
  final String? title;

  /// El estilo del titulo del campo.
  final TextStyle? titleStyle;

  /// La funcion de validacion para el campo.
  final String? Function(String?)? validator;

  /// El tipo de teclado para el campo.
  final TextInputType? keyboardType;

  /// Los formatos de entrada para el campo.
  final List<TextInputFormatter>? inputFormatters;

  /// La accion de entrada para el campo.
  final TextInputAction? textInputAction;

  /// El numero de lineas maximas para el campo.
  final int maxLines;

  /// Indica si el campo debe ocultar el texto ingresado.
  final bool obscureText;

  /// Indica si el campo esta habilitado.
  final bool enabled;

  /// Indica si el campo esta en modo lectura.
  final bool readOnly;

  /// La funcion que se ejecuta cuando el valor del campo cambia.
  final ValueChanged<String>? onChanged;

  /// La funcion que se ejecuta cuando se toca el campo.
  final VoidCallback? onTap;

  /// El texto de ayuda para el campo.
  final String? helperText;

  /// Icono opcional que se muestra al inicio del campo.
  final Widget? prefixIcon;

  /// Icono opcional que se muestra al final del campo.
  final Widget? suffixIcon;

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
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          maxLines: maxLines,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          onChanged: onChanged,
          onTap: onTap,
          style: AppTypography.formFieldValue,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
