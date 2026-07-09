import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

/// Acciones finales del formulario de registro de usuario.
class SignUpActions extends StatelessWidget {
  const SignUpActions({super.key});

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
          onPressed: () {
            // TODO: Conectar con el caso de uso de registro cuando exista.
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: RichText(
            text: const TextSpan(
              style: AppTypography.pageBodyTitle,
              children: [
                TextSpan(text: SignUpStrings.alreadyHaveAccountPrefix),
                TextSpan(
                  text: SignUpStrings.loginLink,
                  style: AppTypography.inlinePrimaryLink,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
