import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/models/sign_up_user_data.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/widgets/sign_up_widgets.dart';
import 'package:go_router/go_router.dart';

/// Pantalla que informa el progreso de creacion de cuenta.
class SignUpCreatingAccountPage extends StatefulWidget {
  const SignUpCreatingAccountPage({required this.userData, super.key});

  final SignUpUserData userData;

  @override
  State<SignUpCreatingAccountPage> createState() =>
      _SignUpCreatingAccountPageState();
}

class _SignUpCreatingAccountPageState extends State<SignUpCreatingAccountPage> {
  static const _stepDuration = Duration(milliseconds: 1200);
  static const List<String> _steps = [
    SignUpStrings.creatingAccountValidateCuit,
    SignUpStrings.creatingAccountVerifyEmail,
    SignUpStrings.creatingAccountGenerateCredentials,
    SignUpStrings.creatingAccountDownloadInitialConfig,
  ];

  Timer? _timer;
  Timer? _completionTimer;
  int _completedSteps = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_stepDuration, _advanceStep);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _completionTimer?.cancel();
    super.dispose();
  }

  void _advanceStep(Timer timer) {
    if (_completedSteps == _steps.length) {
      timer.cancel();
      return;
    }

    setState(() {
      _completedSteps += 1;
    });

    if (_completedSteps == _steps.length) {
      timer.cancel();
      // Espera a que termine la animacion circular antes de cambiar de pantalla.
      _completionTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go(AppRoutes.signUpSuccess, extra: widget.userData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _completedSteps / _steps.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              SignUpProgressCircle(progress: progress),
              const SizedBox(height: AppSpacing.lg),
              const _HeaderTexts(),
              const SizedBox(height: AppSpacing.lg),
              _ValidationSteps(completedSteps: _completedSteps),
              const Spacer(flex: 3),
            ],
          ),
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
          SignUpStrings.creatingAccountTitle,
          style: AppTypography.signUpIntroTitle,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          SignUpStrings.creatingAccountSubtitle,
          style: AppTypography.signUpIntroSubtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ValidationSteps extends StatelessWidget {
  const _ValidationSteps({required this.completedSteps});

  final int completedSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0;
            index < _SignUpCreatingAccountPageState._steps.length;
            index++) ...[
          SignUpProgressStepCard(
            label: _SignUpCreatingAccountPageState._steps[index],
            status: _statusFor(index),
          ),
          if (index < _SignUpCreatingAccountPageState._steps.length - 1)
            const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }

  SignUpProgressStepStatus _statusFor(int index) {
    if (index < completedSteps) {
      return SignUpProgressStepStatus.completed;
    }

    if (index == completedSteps) {
      return SignUpProgressStepStatus.inProgress;
    }

    return SignUpProgressStepStatus.pending;
  }
}
