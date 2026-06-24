import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

class SignUpExistingAccountAlert extends StatelessWidget {
  const SignUpExistingAccountAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        border: Border.all(color: AppColors.errorBorder),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SignUpStrings.existingAccountTitle,
                  style: AppTypography.errorTitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  SignUpStrings.existingAccountMessage,
                  style: AppTypography.errorBody,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: () {
                          // TODO: Navegar a iniciar sesión.
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        child: const Text(
                          SignUpStrings.loginButton,
                          style: AppTypography.errorButton,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    TextButton(
                      onPressed: () {
                        // TODO: Permitir cambiar correo.
                      },
                      child: const Text(
                        SignUpStrings.useAnotherEmailButton,
                        style: AppTypography.errorTextButton,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
