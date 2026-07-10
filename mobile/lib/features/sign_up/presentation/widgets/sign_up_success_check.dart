import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Confirmacion visual principal del alta exitosa.
class SignUpSuccessCheck extends StatelessWidget {
  const SignUpSuccessCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 4),
      ),
      child: const Icon(
        Icons.check,
        color: AppColors.primary,
        size: 58,
      ),
    );
  }
}
