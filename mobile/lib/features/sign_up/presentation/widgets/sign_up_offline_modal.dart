import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

/// Modal que explica que el alta inicial requiere conectividad.
class SignUpOfflineModal extends StatelessWidget {
  const SignUpOfflineModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AppModal(
      leading: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            SignUpStrings.cloudOffIcon,
            width: 34,
            height: 34,
            colorFilter: const ColorFilter.mode(
              AppColors.error,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      title: SignUpStrings.offlineModalTitle,
      message: SignUpStrings.offlineModalMessage,
      content: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Column(
          children: [
            _ConnectivityRecommendation(
              title: SignUpStrings.offlineWifiTitle,
              subtitle: SignUpStrings.offlineWifiSubtitle,
            ),
            SizedBox(height: AppSpacing.sm),
            _ConnectivityRecommendation(
              title: SignUpStrings.offlineMobileDataTitle,
              subtitle: SignUpStrings.offlineMobileDataSubtitle,
            ),
          ],
        ),
      ),
      action: AppFilledButton(
        label: SignUpStrings.retryButton,
        icon: SvgPicture.asset(
          SignUpStrings.cachedIcon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            AppColors.onPrimary,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Opcion breve que sugiere una fuente de conexion para completar el alta.
class _ConnectivityRecommendation extends StatelessWidget {
  const _ConnectivityRecommendation({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              SignUpStrings.cloudIcon,
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.connectivityRecommendationTitle,
              ),
              Text(
                subtitle,
                style: AppTypography.connectivityRecommendationSubtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
