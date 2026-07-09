import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/auth/presentation/strings/login_strings.dart';

/// Encabezado visual de la pantalla de login.
class LoginHeader extends StatelessWidget {
  /// Crea el encabezado con marca y texto introductorio.
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: AppColors.onPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          LoginStrings.title,
          style: AppTypography.bigTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          LoginStrings.subtitle,
          style: AppTypography.pageBodyTitle,
        ),
      ],
    );
  }
}
