import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

/// Estado visual de un paso de validacion durante el registro.
enum SignUpProgressStepStatus {
  /// El paso ya finalizo correctamente.
  completed,

  /// El paso se esta validando actualmente.
  inProgress,

  /// El paso todavia no empezo.
  pending,
}

/// Tarjeta de estado para una validacion de creacion de cuenta.
class SignUpProgressStepCard extends StatelessWidget {
  const SignUpProgressStepCard({
    required this.label,
    required this.status,
    super.key,
  });

  /// Texto principal del paso.
  final String label;

  /// Estado visual del paso.
  final SignUpProgressStepStatus status;

  @override
  Widget build(BuildContext context) {
    final isInProgress = status == SignUpProgressStepStatus.inProgress;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            _StepStatusIcon(status: status),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: isInProgress
                    ? AppTypography.progressStepActive
                    : AppTypography.progressStepInactive,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isInProgress) ...[
              const SizedBox(width: AppSpacing.sm),
              const _InProgressBadge(),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepStatusIcon extends StatelessWidget {
  const _StepStatusIcon({required this.status});

  final SignUpProgressStepStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      SignUpProgressStepStatus.completed => const _CompletedIcon(),
      SignUpProgressStepStatus.inProgress => const _LoadingIcon(),
      SignUpProgressStepStatus.pending => const _PendingIcon(),
    };
  }
}

class _CompletedIcon extends StatelessWidget {
  const _CompletedIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          SignUpStrings.checkIcon,
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(
            AppColors.onPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _LoadingIcon extends StatefulWidget {
  const _LoadingIcon();

  @override
  State<_LoadingIcon> createState() => _LoadingIconState();
}

class _LoadingIconState extends State<_LoadingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.termsBackground,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            SignUpStrings.cachedIcon,
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingIcon extends StatelessWidget {
  const _PendingIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.termsBackground,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _InProgressBadge extends StatelessWidget {
  const _InProgressBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          SignUpStrings.creatingAccountInProgress,
          style: AppTypography.formFieldSuccess,
        ),
      ),
    );
  }
}
