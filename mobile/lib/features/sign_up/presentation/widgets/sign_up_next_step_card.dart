import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

/// Presenta la accion recomendada luego de crear la cuenta.
class SignUpNextStepCard extends StatelessWidget {
  const SignUpNextStepCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.nextStepBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NextStepIcon(),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SignUpStrings.nextStepTitle,
                  style: AppTypography.formFieldSuccess,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  SignUpStrings.nextStepDescription,
                  style: AppTypography.formFieldHelper,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepIcon extends StatelessWidget {
  const _NextStepIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Icon(
        Icons.layers_outlined,
        color: AppColors.onPrimary,
        size: 22,
      ),
    );
  }
}
