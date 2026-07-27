import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/strings/sign_up_strings.dart';

/// Bloque introductorio del formulario de registro.
class SignUpIntro extends StatelessWidget {
  /// Crea la introduccion del registro.
  const SignUpIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SignUpStrings.introTitle,
          style: AppTypography.signUpIntroTitle,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          SignUpStrings.introSubtitle,
          style: AppTypography.signUpIntroSubtitle,
        ),
      ],
    );
  }
}
