import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

/// Indicador circular de avance para la creacion de cuenta.
class SignUpProgressCircle extends StatelessWidget {
  const SignUpProgressCircle({
    required this.progress,
    super.key,
  });

  /// Progreso normalizado entre 0 y 1.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, _) {
        return SizedBox.square(
          dimension: 112,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: 4,
                  backgroundColor: AppColors.termsBackground,
                  color: AppColors.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              SvgPicture.asset(
                SignUpStrings.cloudIcon,
                width: 40,
                height: 40,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
