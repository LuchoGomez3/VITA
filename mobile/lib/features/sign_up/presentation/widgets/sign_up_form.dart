import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

/// Formulario visual del alta de usuario.
class SignUpForm extends StatelessWidget {
  const SignUpForm({
    required this.hasPasswordError,
    required this.isCuitValid,
    required this.isEmailAlreadyRegistered,
    super.key,
  });

  /// Indica si se debe mostrar la ayuda de requisitos de contrasena.
  final bool hasPasswordError;

  /// Estado visual de validacion del CUIT/CUIL ingresado.
  final bool isCuitValid;

  /// Estado visual para alertar que el correo ya existe.
  final bool isEmailAlreadyRegistered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: AppTextFormField(
                title: SignUpStrings.firstNameLabel,
                hintText: SignUpStrings.emptyInputHint,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextFormField(
                title: SignUpStrings.lastNameLabel,
                hintText: SignUpStrings.emptyInputHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _SignUpCuitField(isValid: isCuitValid),
        const SizedBox(height: AppSpacing.md),
        _SignUpEmailField(alreadyRegistered: isEmailAlreadyRegistered),
        const SizedBox(height: AppSpacing.md),
        _SignUpPasswordField(hasPasswordError: hasPasswordError),
      ],
    );
  }
}

class _SignUpEmailField extends StatelessWidget {
  const _SignUpEmailField({
    required this.alreadyRegistered,
  });

  final bool alreadyRegistered;

  @override
  Widget build(BuildContext context) {
    return _SignUpValidatedInput(
      title: const Text(
        SignUpStrings.emailLabel,
        style: AppTypography.secondaryEmphasis,
      ),
      initialValue: SignUpStrings.emailMockValue,
      statusText: alreadyRegistered
          ? SignUpStrings.emailAlreadyRegisteredMessage
          : SignUpStrings.emailAvailableMessage,
      isError: alreadyRegistered,
    );
  }
}

class _SignUpCuitField extends StatelessWidget {
  const _SignUpCuitField({
    required this.isValid,
  });

  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return _SignUpValidatedInput(
      title: RichText(
        text: const TextSpan(
          style: AppTypography.secondaryEmphasis,
          children: [
            TextSpan(text: SignUpStrings.cuitLabel),
            TextSpan(
              text: SignUpStrings.cuitRenspaSuffix,
              style: AppTypography.pageBodyTitle,
            ),
          ],
        ),
      ),
      initialValue: SignUpStrings.cuitMockValue,
      statusText: isValid
          ? SignUpStrings.cuitValidMessage
          : SignUpStrings.cuitInvalidMessage,
      isError: !isValid,
    );
  }
}

class _SignUpPasswordField extends StatefulWidget {
  const _SignUpPasswordField({
    required this.hasPasswordError,
  });

  final bool hasPasswordError;

  @override
  State<_SignUpPasswordField> createState() => _SignUpPasswordFieldState();
}

class _SignUpPasswordFieldState extends State<_SignUpPasswordField> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          SignUpStrings.passwordLabel,
          style: AppTypography.secondaryEmphasis,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          obscureText: !_isPasswordVisible,
          style: AppTypography.formFieldValue,
          decoration: InputDecoration(
            hintText: SignUpStrings.passwordHint,
            suffixIcon: IconButton(
              onPressed: _togglePasswordVisibility,
              icon: SvgPicture.asset(
                _isPasswordVisible
                    ? SignUpStrings.visibilityOffIcon
                    : SignUpStrings.visibilityIcon,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  Colors.black38,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        if (widget.hasPasswordError) ...[
          const SizedBox(height: AppSpacing.xs),
          const Text(
            SignUpStrings.passwordRequirements,
            style: AppTypography.formFieldHelper,
          ),
        ],
      ],
    );
  }
}

class _SignUpValidatedInput extends StatelessWidget {
  const _SignUpValidatedInput({
    required this.title,
    required this.initialValue,
    required this.statusText,
    required this.isError,
  });

  final Widget title;
  final String initialValue;
  final String statusText;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    // Reutiliza el mismo patron visual para validaciones inmediatas de CUIT y correo.
    final statusColor = isError ? AppColors.error : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          initialValue: initialValue,
          style: AppTypography.formFieldValueEmphasis,
          decoration: InputDecoration(
            suffixIcon: Icon(
              isError ? Icons.error_outline : Icons.check,
              color: statusColor,
              size: 20,
            ),
            enabledBorder: _statusBorder(statusColor),
            focusedBorder: _statusBorder(statusColor),
            border: _statusBorder(statusColor),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          statusText,
          style: isError
              ? AppTypography.formFieldError
              : AppTypography.formFieldSuccess,
        ),
      ],
    );
  }
}

OutlineInputBorder _statusBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.sm),
    borderSide: BorderSide(color: color),
  );
}
