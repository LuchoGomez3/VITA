import 'package:flutter/material.dart';

/// Tokens de color oficiales de la app mobile.
///
/// La idea es que widgets, pages y el tema global consuman colores desde aca
/// para mantener consistencia visual y evitar hex sueltos en la UI.
class AppColors {
  const AppColors._();

  /// Verde principal de la marca.
  ///
  /// Se usa en acciones principales: botones filled, progreso, highlights,
  /// bordes/accentos e indicadores interactivos.
  static const primary = Color(0xFF2E7D32);

  /// Color de contenido sobre superficies `primary`.
  static const onPrimary = Color(0xFFFFFFFF);

  static const surface = Color(0xFFFFFFFF);

  /// Color de contenido sobre superficies `error`.
  static const onError = Color(0xFFFFFFFF);

  /// Fondo base de la aplicacion.
  static const background = Color(0xFFF8F5F0);

  /// Fondo alternativo para secciones con mayor enfasis visual.
  static const backgroundSecondary = Color(0xFFC3F2CB);

  /// Fondo alternativo para secciones con mayor enfasis visual.
  static const backgroundSecondaryLight = Color.fromARGB(255, 221, 255, 227);

  /// Fondo alternativo neutro para tarjetas o bloques destacados.
  static const backgroundTertiary = Color(0xFFE8E2D2);

  /// Fondo suave para tarjetas legales o de terminos.
  static const termsBackground = Color(0xFFF3EFE9);

  /// Texto principal: titulos de app bar, botones de texto y contenido clave.
  static const textPrimary = Color(0xFF1D1B1A);

  /// Texto secundario: subtitulos, headers de seccion y apoyo visual.
  static const textSecondary = Color(0xFF6D4C41);

  /// Texto destacado para pantallas de registro y condiciones legales.
  static const textEmphasis = Color(0xFF3E2723);

  /// Texto de ayuda o placeholder en campos de formulario.
  static const textHint = Color(0xFF9E8B84);

  /// Borde neutro para inputs, cards y divisores suaves.
  static const border = Color(0xFFE1D3CF);

  
  /// Borde de chips.
  static const chipBorder = Color(0xFFE0E0E0);

  /// Borde para contenedores de validacion positiva.
  static const borderPositiveContainer = Color(0xFF80CBC4);

  /// Fondo para contenedores de validacion positiva.
  static const backgroundPositiveContainer = Color(0xFFE0F2F1);

  /// Color icono check
  static const checkIcon = Color(0xFF00897B);

  /// Color texto
  static const positiveText = Color(0xFF004D40);

  /// Borde neutro para controles checkbox sin seleccionar.
  static const checkboxBorder = Color(0x42000000);

  /// Color principal para estados de error.
  static const error = Color(0xFFD32F2F);

  /// Fondo suave para bloques de error.
  static const errorContainer = Color(0xFFFFEBEE);

  /// Borde para bloques o campos en estado de error.
  static const errorBorder = Color(0xFFE53935);

  /// Color principal para estados de advertencia (severidad intermedia).
  static const warning = Color(0xFFF9A825);

  /// Amarillo usado para indicar una contraseña de fuerza normal.
  static const passwordStrengthNormal = Color(0xFFF9A825);

  /// Verde intenso usado para indicar una contraseña muy fuerte.
  static const passwordStrengthVeryStrong = Color(0xFF1B5E20);

  /// Scrim suave para modales livianos.
  static const modalBarrier = Color(0x14000000);

  /// Fondo suave para botones iconicos sobre superficies claras.
  static const iconButtonBackground = Color(0x0D000000);

  /// Color atenuado para iconos secundarios sobre superficies claras.
  static const iconMuted = Color(0x61000000);

  /// Sombra suave utilizada por tarjetas elevadas.
  static const cardShadow = Color(0x12000000);

  /// Fondo verde tenue para bloques informativos de siguiente paso.
  static const nextStepBackground = Color(0x61C3F2CB);

  /// Opciones disponibles para personalizacion de caravanas.
  /// Opcion amarilla
  static const earTagYellow = Color(0xFFF4CF3D);

  /// Opcion lilac
  static const earTagLilac = Color(0xFFE5D1E3);

  /// Opcion naranja
  static const earTagOrange = Color(0xFFE76B3A);

  /// Opcion azul usada por caravanas mock en genealogia.
  static const earTagBlue = Color(0xFF7CB6E8);

  /// Mapeo de los colores oficiales al sistema de tema de Flutter.
  ///
  /// Mantener este esquema manual evita que `ColorScheme.fromSeed` genere
  /// tonos que no coincidan con la paleta aprobada por diseno.
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    secondary: textSecondary,
    onSecondary: onPrimary,
    error: error,
    onError: onPrimary,
    surface: onPrimary,
    onSurface: textPrimary,
    outline: border,
    outlineVariant: border,
    shadow: Color(0x1A1D1B1A),
    scrim: Color(0x521D1B1A),
    inverseSurface: textPrimary,
    onInverseSurface: onPrimary,
    inversePrimary: Color(0xFFA5D6A7),
    surfaceTint: primary,
  );
}
