import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_logo.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/strings/login_strings.dart';

/// Encabezado visual de la pantalla de login.
class LoginHeader extends StatelessWidget {
  /// Crea el encabezado con marca y texto introductorio.
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppLogo(size: 56, borderRadius: AppRadius.md),
        SizedBox(height: AppSpacing.lg),
        Text(
          LoginStrings.title,
          style: AppTypography.bigTitle,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          LoginStrings.subtitle,
          style: AppTypography.pageBodyTitle,
        ),
      ],
    );
  }
}
