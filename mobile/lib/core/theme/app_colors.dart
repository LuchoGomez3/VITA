import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF255C3D);
  static const background = Color(0xFFF6F3EC);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFD7D3C8);
  static const textPrimary = Color(0xFF18261D);
  static const textSecondary = Color(0xFF5F6E65);

  static ColorScheme lightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
    );
  }

  const AppColors._();
}
