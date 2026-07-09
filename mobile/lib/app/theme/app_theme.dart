import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Tema de la app.
class AppTheme {
  /// Crea un nuevo tema de la app.
  const AppTheme._();

  /// Crea un nuevo tema de la app.
  static ThemeData light() {
    /// Color scheme de la app.
    const colorScheme = AppColors.lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme(),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: AppTypography.appBarTitle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTypography.formFieldHint,
        labelStyle: AppTypography.secondaryEmphasis,
        helperStyle: AppTypography.formFieldSuccess,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTypography.filledButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          textStyle: AppTypography.outlinedButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
    );
  }
}
