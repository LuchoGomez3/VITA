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

  /// Titulo compacto centrado para headers de flujo.
  static const flowHeaderTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
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

  /// Texto de ayuda o validacion negativa debajo de un input.
  static const formFieldError = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.error,
  );

  /// Sufijo aclaratorio de labels de formulario.
  static const formFieldLabelSuffix = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Texto de ayuda neutro debajo de un campo de formulario.
  static const formFieldHelper = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Valor destacado dentro de un input.
  static const formFieldValueEmphasis = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
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

  /// Titulo de alerta de error.
  static const errorTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.error,
  );

  /// Texto descriptivo de alerta de error.
  static const errorBody = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
    height: 1.35,
  );

  /// Texto para botones pequenos dentro de alertas de error.
  static const errorButton = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onPrimary,
  );

  /// Texto para acciones secundarias dentro de alertas de error.
  static const errorTextButton = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.error,
  );

  /// Titulo grande para pantallas de resultado o confirmacion.
  static const successTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Titulo principal de la pantalla de registro.
  static const signUpIntroTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Color(0xFF3E2723),
  );

  /// Subtitulo de la pantalla de registro.
  static const signUpIntroSubtitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
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

  /// Texto base de la tarjeta de terminos del registro.
  static const termsBody = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF3E2723),
    height: 1.4,
  );

  /// Texto destacado de la tarjeta de terminos del registro.
  static const termsEmphasis = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFF3E2723),
    height: 1.4,
  );

  /// Link destacado de la tarjeta de terminos del registro.
  static const termsLink = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.4,
  );

  /// Link primario inline.
  static const inlinePrimaryLink = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  /// Titulo principal de modal de conectividad.
  static const connectivityModalTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Color(0xFF3E2723),
  );

  /// Texto descriptivo de modal de conectividad.
  static const connectivityModalBody = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.35,
  );

  /// Titulo de recomendacion dentro del modal de conectividad.
  static const connectivityRecommendationTitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Subtitulo de recomendacion dentro del modal de conectividad.
  static const connectivityRecommendationSubtitle = TextStyle(
    fontFamily: _baseFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

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
