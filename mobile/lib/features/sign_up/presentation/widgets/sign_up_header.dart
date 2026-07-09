import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';
import 'package:go_router/go_router.dart';

/// Encabezado del registro con navegacion y estado visual de conectividad.
class SignUpHeader extends StatelessWidget {
  const SignUpHeader({
    super.key,
    this.isOffline = false,
  });

  /// Cambia el icono de conectividad mientras se muestra el modal offline.
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: SvgPicture.asset(
            SignUpStrings.arrowBackIcon,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.iconButtonBackground,
            padding: const EdgeInsets.all(AppSpacing.sm),
          ),
        ),
        const Text(
          SignUpStrings.pageTitle,
          style: AppTypography.outlinedButton,
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isOffline ? AppColors.errorContainer : AppColors.backgroundSecondary,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            isOffline ? SignUpStrings.cloudOffIcon : SignUpStrings.cloudIcon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              isOffline ? AppColors.error : AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
