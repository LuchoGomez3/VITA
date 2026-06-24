import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/widgets/widgets.dart';

/// Pantalla de creación de cuenta (Registro de usuario).
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isOfflineModalOpen = false;

  Future<void> _showOfflineModal() async {
    setState(() {
      _isOfflineModalOpen = true;
    });

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.08),
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
                const SignUpExistingAccountAlert(),
                const SizedBox(height: AppSpacing.lg),
              ],
              const SignUpIntro(),
              const SizedBox(height: AppSpacing.lg),
              const SignUpForm(
                hasPasswordError: hasPasswordError,
                isCuitValid: isCuitValid,
                isEmailAlreadyRegistered: isEmailAlreadyRegistered,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!showExistingAccountAlert) ...[
                const SignUpTermsCard(),
                const SizedBox(height: AppSpacing.lg),
              ],
              const SignUpActions(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
