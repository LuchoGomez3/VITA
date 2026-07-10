import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/models/sign_up_user_data.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/widgets/sign_up_widgets.dart';
import 'package:go_router/go_router.dart';

/// Pantalla final del alta de dueño.
class SignUpSuccessPage extends StatelessWidget {
  const SignUpSuccessPage({required this.userData, super.key});

  final SignUpUserData userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const SignUpSuccessCheck(),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${SignUpStrings.successWelcomePrefix}'
                '${userData.firstName}'
                '${SignUpStrings.successWelcomeSuffix}',
                style: AppTypography.signUpIntroTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                SignUpStrings.successSubtitle,
                style: AppTypography.signUpIntroSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SignUpUserSummaryCard(userData: userData),
              const SizedBox(height: AppSpacing.md),
              const SignUpNextStepCard(),
              const Spacer(flex: 3),
              AppFilledButton(
                label: SignUpStrings.configureEstablishmentButton,
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  // TODO(FRANCO): navegar a la configuracion del primer establecimiento.
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // TODO(FRANCO): retirar cuando el flujo de establecimientos este completo.
              AppOutlinedButton(
                label: SignUpStrings.temporaryBackHomeButton,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
