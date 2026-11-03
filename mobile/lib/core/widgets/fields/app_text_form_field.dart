import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Estado visual inmediato de un campo de formulario.
enum AppFieldValidation {
  /// El campo conserva el aspecto neutro definido por el tema.
  neutral,

  /// El campo muestra una validacion satisfactoria.
  valid,

  /// El campo muestra una validacion fallida.
  invalid,
}

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
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.title,
    this.titleStyle,
    this.validator,
    this.validation = AppFieldValidation.neutral,
    this.validationMessage,
    this.validationMessageMinHeight,
    this.maxCharacters,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.maxLines = 1,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.helperText,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.titleWidget,
    this.style,
  });

  /// El controlador del campo de texto.
  final TextEditingController? controller;

  /// El nodo que permite controlar el foco desde el formulario propietario.
  final FocusNode? focusNode;

  /// El texto de ayuda para el campo.
  final String? hintText;

  /// El titulo del campo.
  final String? title;

  /// El estilo del titulo del campo.
  final TextStyle? titleStyle;

  /// La funcion de validacion para el campo.
  final String? Function(String?)? validator;

  /// Estado visual que determina el color del borde y del mensaje de ayuda.
  final AppFieldValidation validation;

  /// Mensaje asociado al estado de validacion inmediato.
  final String? validationMessage;

  /// Alto minimo reservado para evitar saltos al mostrar la validacion.
  final double? validationMessageMinHeight;

  /// Cantidad maxima de caracteres aceptados por el campo.
  final int? maxCharacters;

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

  /// Indica si el teclado puede corregir automaticamente el texto.
  final bool autocorrect;

  /// Indica si el teclado puede mostrar sugerencias.
  final bool enableSuggestions;

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

  /// Texto fijo que se muestra antes del valor ingresado.
  final String? prefixText;

  /// Icono opcional que se muestra al final del campo.
  final Widget? suffixIcon;

  /// Titulo personalizado usado cuando un texto simple no es suficiente.
  final Widget? titleWidget;

  /// Estilo del texto ingresado. Por defecto usa `AppTypography.formFieldValue`.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle ?? AppTypography.secondaryEmphasis;
    final validationColor = switch (validation) {
      AppFieldValidation.neutral => null,
      AppFieldValidation.valid => AppColors.primary,
      AppFieldValidation.invalid => AppColors.error,
    };
    final effectiveFormatters = [
      ...?inputFormatters,
      if (maxCharacters case final maxCharacters?) LengthLimitingTextInputFormatter(maxCharacters),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titleWidget != null || title != null) ...[
          titleWidget ?? Text(title!, style: effectiveTitleStyle),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: effectiveFormatters,
          textInputAction: textInputAction,
          maxLines: maxLines,
          obscureText: obscureText,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          enabled: enabled,
          readOnly: readOnly,
          onChanged: onChanged,
          onTap: onTap,
          style: style ?? AppTypography.formFieldValue,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            suffixIcon: suffixIcon,
            enabledBorder: _validationBorder(validationColor),
            focusedBorder: _validationBorder(validationColor),
            border: _validationBorder(validationColor),
          ),
        ),
        if (validationMessage != null || validationMessageMinHeight != null) ...[
          const SizedBox(height: AppSpacing.xs),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: validationMessageMinHeight ?? 0,
            ),
            child: validationMessage != null
                ? Text(
                    validationMessage!,
                    style: validation == AppFieldValidation.invalid
                        ? AppTypography.formFieldError
                        : AppTypography.formFieldSuccess,
                  )
                : null,
          ),
        ],
      ],
    );
  }
}

OutlineInputBorder? _validationBorder(Color? color) {
  if (color == null) {
    return null;
  }
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.sm),
    borderSide: BorderSide(color: color),
  );
}
