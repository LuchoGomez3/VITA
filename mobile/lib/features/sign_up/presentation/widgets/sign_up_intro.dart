import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

class SignUpIntro extends StatelessWidget {
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
