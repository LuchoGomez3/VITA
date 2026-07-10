import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/buttons/buttons.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

/// Alerta mostrada cuando el CUIT o correo ya pertenece a una cuenta activa.
class SignUpExistingAccountAlert extends StatelessWidget {
  const SignUpExistingAccountAlert({
    required this.onLoginPressed,
    super.key,
  });

  /// Accion ejecutada al elegir iniciar sesion con la cuenta existente.
  final VoidCallback onLoginPressed;

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
                const Text(
                  SignUpStrings.existingAccountTitle,
                  style: AppTypography.errorTitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  SignUpStrings.existingAccountMessage,
                  style: AppTypography.errorBody,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    AppErrorFilledButton(
                      label: SignUpStrings.loginButton,
                      onPressed: onLoginPressed,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    TextButton(
                      onPressed: () {
                        // TODO: Limpiar el correo y volver al estado editable del formulario.
                      },
                      child: const Text(
                        SignUpStrings.useAnotherEmailButton,
                        style: AppTypography.errorTitle,
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
