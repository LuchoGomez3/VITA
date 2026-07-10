import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/models/sign_up_user_data.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/widgets/sign_up_widgets.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de creación de cuenta (Registro de usuario).
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController(
    text: SignUpStrings.firstNameMockValue,
  );
  final _lastNameController = TextEditingController(
    text: SignUpStrings.lastNameMockValue,
  );
  final _emailController = TextEditingController(
    text: SignUpStrings.emailMockValue,
  );
  final _cuitController = TextEditingController(
    text: SignUpStrings.cuitMockValue,
  );

  /// Refleja el estado del modal para que el header muestre conectividad offline.
  bool _isOfflineModalOpen = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cuitController.dispose();
    super.dispose();
  }

  SignUpUserData get _userData => SignUpUserData(
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    email: _emailController.text.trim(),
    cuit: _cuitController.text.trim(),
  );

  Future<void> _showOfflineModal() async {
    setState(() {
      _isOfflineModalOpen = true;
    });

    await showDialog<void>(
      context: context,
      barrierColor: AppColors.modalBarrier,
      builder: (context) => const SignUpOfflineModal(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isOfflineModalOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Estados mockeados hasta conectar el formulario con validacion real.
    const showExistingAccountAlert = true;
    const hasPasswordError = false;
    const isCuitValid = true;
    const isEmailAlreadyRegistered = true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SignUpHeader(isOffline: _isOfflineModalOpen),
              const SizedBox(height: AppSpacing.md),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showOfflineModal,
                  child: const Text(SignUpStrings.offlinePreviewButton),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (showExistingAccountAlert) ...[
                SignUpExistingAccountAlert(
                  onLoginPressed: () => context.push(AppRoutes.login),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              const SignUpIntro(),
              const SizedBox(height: AppSpacing.lg),
              SignUpForm(
                cuitController: _cuitController,
                emailController: _emailController,
                firstNameController: _firstNameController,
                hasPasswordError: hasPasswordError,
                isCuitValid: isCuitValid,
                isEmailAlreadyRegistered: isEmailAlreadyRegistered,
                lastNameController: _lastNameController,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!showExistingAccountAlert) ...[
                const SignUpTermsCard(),
                const SizedBox(height: AppSpacing.lg),
              ],
              SignUpActions(
                onLoginPressed: () {
                  context.push(AppRoutes.login);
                },
                onRegisterPressed: () {
                  context.push(
                    AppRoutes.signUpCreatingAccount,
                    extra: _userData,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
