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

  /// Fondo base de la aplicacion.
  static const background = Color(0xFFF8F5F0);

  /// Fondo alternativo para secciones con mayor enfasis visual.
  static const backgroundSecondary = Color(0xFFC3F2CB);

  /// Fondo alternativo neutro para tarjetas o bloques destacados.
  static const backgroundTertiary = Color(0xFFE8E2D2);

  /// Superficie principal para cards, inputs y componentes elevados.
  static const surface = Color(0xFFFFFFFF);

  /// Texto principal: titulos de app bar, botones de texto y contenido clave.
  static const textPrimary = Color(0xFF1D1B1A);

  /// Texto secundario: subtitulos, headers de seccion y apoyo visual.
  static const textSecondary = Color(0xFF6D4C41);

  /// Texto de ayuda o placeholder en campos de formulario.
  static const textHint = Color(0xFF9E8B84);

  /// Color usado para estados de error.
  static const error = Color(0xFFB3261E);

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

  /// Opciones disponibles para personalizacion de caravanas.
  /// Opcion amarilla
  static const earTagYellow = Color(0xFFF4CF3D);

  /// Opcion beige
  static const earTagBeige = Color(0xFFE8E2D2);

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
    surface: surface,
    onSurface: textPrimary,
    outline: border,
    outlineVariant: border,
    shadow: Color(0x1A1D1B1A),
    scrim: Color(0x521D1B1A),
    inverseSurface: textPrimary,
    onInverseSurface: surface,
    inversePrimary: Color(0xFFA5D6A7),
    surfaceTint: primary,
  );
}
