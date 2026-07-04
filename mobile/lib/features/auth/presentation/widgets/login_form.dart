import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/validators/validators.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/auth/presentation/strings/login_strings.dart';

/// Formulario de credenciales de la pantalla de login.
class LoginForm extends StatelessWidget {
  /// Crea el formulario con controladores y callbacks provistos por la pagina.
  const LoginForm({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onPasswordVisibilityPressed,
    required this.onSubmit,
    super.key,
  });

  /// Clave del formulario para validar desde la pagina.
  final GlobalKey<FormState> formKey;

  /// Controlador del campo usuario.
  final TextEditingController usernameController;

  /// Controlador del campo contraseña.
  final TextEditingController passwordController;

  /// Indica si la contraseña debe mostrarse oculta.
  final bool obscurePassword;

  /// Indica si el submit esta en curso.
  final bool isSubmitting;

  /// Alterna la visibilidad del campo contraseña.
  final VoidCallback onPasswordVisibilityPressed;

  /// Ejecuta el submit del formulario.
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppTextFormField(
            controller: usernameController,
            title: LoginStrings.usernameLabel,
            hintText: LoginStrings.usernameHint,
            enabled: !isSubmitting,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) => FormValidators.requiredField(
              value,
              message: LoginStrings.usernameRequired,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextFormField(
            controller: passwordController,
            title: LoginStrings.passwordLabel,
            hintText: LoginStrings.passwordHint,
            enabled: !isSubmitting,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: isSubmitting ? null : onPasswordVisibilityPressed,
              icon: Icon(
                obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) => FormValidators.requiredField(
              value,
              message: LoginStrings.passwordRequired,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppFilledButton(
            label: LoginStrings.submitButton,
            loadingLabel: LoginStrings.submittingButton,
            isLoading: isSubmitting,
            icon: const Icon(Icons.login),
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
