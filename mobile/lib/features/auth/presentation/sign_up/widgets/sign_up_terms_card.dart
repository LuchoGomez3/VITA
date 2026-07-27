import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/strings/sign_up_strings.dart';

/// Tarjeta de aceptacion de terminos del flujo de registro.
class SignUpTermsCard extends StatefulWidget {
  /// Crea la tarjeta de terminos y privacidad.
  const SignUpTermsCard({super.key});

  @override
  State<SignUpTermsCard> createState() => _SignUpTermsCardState();
}

class _SignUpTermsCardState extends State<SignUpTermsCard> {
  /// Estado local hasta que el formulario conecte su validacion real.
  bool _isAccepted = false;

  void _toggleAccepted() {
    setState(() {
      _isAccepted = !_isAccepted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Permite alternar el checkbox tocando cualquier punto de la tarjeta.
      behavior: HitTestBehavior.opaque,
      onTap: _toggleAccepted,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.termsBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _isAccepted,
                onChanged: (value) {
                  setState(() {
                    _isAccepted = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: const BorderSide(
                  color: AppColors.checkboxBorder,
                  width: 1.5,
                ),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: AppTypography.termsBody,
                  children: [
                    TextSpan(text: SignUpStrings.termsPrefix),
                    TextSpan(
                      text: SignUpStrings.termsOwner,
                      style: AppTypography.termsEmphasis,
                    ),
                    TextSpan(text: SignUpStrings.termsMiddle),
                    TextSpan(
                      text: SignUpStrings.termsPrivacy,
                      style: AppTypography.termsLink,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
