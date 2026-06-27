import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/app_colors.dart';

/// Tokens tipograficos oficiales de la app mobile.
///
/// Este archivo centraliza tamanos, pesos y colores de texto para que las
/// pantallas reutilicen estilos consistentes y no definan `TextStyle` sueltos.
class AppTypography {
  const AppTypography._();
  // TODO(branding): cambiar a 'Poppins' cuando la fuente este agregada
  // en assets/fonts y declarada en pubspec.yaml.
  static const _baseFontFamily = 'sans-serif';

  /// Titulo principal del app bar.
  static const appBarTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Subtitulo complementario del app bar.
  static const appBarSubtitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// Titulo corto de pagina o encabezado de seccion.
  static const pageTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  /// Texto de apoyo para bloques de contenido o subtitulos de pagina.
  static const pageBodyTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Label visible de campos de formulario.
  static const formFieldLabel = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// Texto que escribe o visualiza el usuario dentro del input.
  static const formFieldValue = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Hint o placeholder de campos de formulario.
  static const formFieldHint = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  /// Texto de ayuda o validacion positiva debajo de un input.
  static const formFieldSuccess = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  /// Texto para botones de seleccion de fecha predeterminada hoy, mes, 30 dias, ultimos 7 dias.
  static const datePickerChip = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  /// Texto pequeno con enfasis, util para microcopys o metadata.
  static const smallEmphasis = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  /// Texto pequeno con enfasis, util para microcopys o metadata.
  static const mediumEmphasis = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// Texto Validacion Positiva
  static const positiveText = TextStyle(color: AppColors.positiveText, fontWeight: FontWeight.w500, fontSize: 13);

  /// Titulo grande para pantallas de resultado o confirmacion.
  static const successTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Subtitulo destacado para pantallas de resultado o confirmacion.
  static const successSubtitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// Texto para acciones primarias en botones filled.
  static const filledButton = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.onPrimary,
  );

  /// Texto para acciones secundarias en botones outlined.
  static const outlinedButton = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Text style for selectable chips that changes with selection state.
  static TextStyle selectableChipStyle({required bool isSelected}) {
    return TextStyle(
      fontSize: 13,
      color: isSelected ? Colors.white : Colors.grey.shade800,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
    );
  }

  /// Adaptacion de los estilos oficiales al `TextTheme` de Flutter.
  ///
  /// Esto permite que widgets Material reutilicen la tipografia base sin que
  /// cada pantalla tenga que mapear los estilos manualmente.
  static TextTheme textTheme() {
    return const TextTheme(
      headlineMedium: pageTitle,
      headlineSmall: pageTitle,
      titleLarge: pageBodyTitle,
      titleMedium: formFieldLabel,
      bodyLarge: formFieldValue,
      bodyMedium: pageBodyTitle,
      bodySmall: smallEmphasis,
      labelLarge: filledButton,
      labelMedium: outlinedButton,
      labelSmall: appBarSubtitle,
    );
  }
}
