import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';
import 'package:go_router/go_router.dart';

/// Pantalla inicial para usuarios que aun no tienen cuenta.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(flex: 2),
              _LogoPlaceholder(),
              SizedBox(height: AppSpacing.lg),
              _HeaderTexts(),
              Spacer(flex: 3),
              _ActionButtons(),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
// TODO: (FRANCO) Agregar imagen de la empresa en lugar del placeholder.
class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.face_retouching_natural,
          color: AppColors.onPrimary,
          size: 48,
        ),
      ),
    );
  }
}

class _HeaderTexts extends StatelessWidget {
  const _HeaderTexts();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          WelcomeStrings.title,
          style: AppTypography.welcomeTitle,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          WelcomeStrings.subtitle,
          style: AppTypography.pageBodyTitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFilledButton(
          label: WelcomeStrings.createAccountButton,
          icon: const Icon(Icons.add),
          onPressed: () {
            context.push(AppRoutes.signUpForm);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppOutlinedButton(
          label: WelcomeStrings.loginButton,
          onPressed: () {
            context.push(AppRoutes.login);
          },
        ),
      ],
    );
  }
}
