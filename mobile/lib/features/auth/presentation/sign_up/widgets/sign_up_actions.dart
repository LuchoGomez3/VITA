import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/strings/sign_up_strings.dart';

/// Acciones finales del formulario de registro de usuario.
class SignUpActions extends StatelessWidget {
  /// Crea las acciones de registro e inicio de sesion.
  const SignUpActions({
    required this.isSubmitting,
    required this.onLoginPressed,
    required this.onRegisterPressed,
    super.key,
  });

  /// Indica si el registro esta siendo procesado.
  final bool isSubmitting;

  /// Accion ejecutada al seleccionar el enlace de inicio de sesion.
  final VoidCallback onLoginPressed;

  /// Accion ejecutada al enviar el formulario de registro.
  final VoidCallback? onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppFilledButton(
          label: SignUpStrings.registerButton,
          icon: SvgPicture.asset(
            SignUpStrings.arrowForwardIcon,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.onPrimary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: onRegisterPressed,
          isLoading: isSubmitting,
          loadingLabel: SignUpStrings.registeringButton,
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: RichText(
            text: TextSpan(
              style: AppTypography.pageBodyTitle,
              children: [
                const TextSpan(
                  text: SignUpStrings.alreadyHaveAccountPrefix,
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Semantics(
                    link: true,
                    child: GestureDetector(
                      onTap: onLoginPressed,
                      child: const Text(
                        SignUpStrings.loginLink,
                        style: AppTypography.inlinePrimaryLink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
