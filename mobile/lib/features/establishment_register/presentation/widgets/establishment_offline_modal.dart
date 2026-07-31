import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

/// Modal que explica que crear el establecimiento requiere conectividad.
///
/// Mismo patrón que `SignUpOfflineModal` (duplicado localmente a propósito,
/// ver `.claude/specs/registrar-establecimiento.md`): el registro de
/// establecimiento es online-only, igual que el alta de dueño.
class EstablishmentOfflineModal extends StatelessWidget {
  /// Crea el modal de falta de conexión.
  const EstablishmentOfflineModal({super.key});

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
            EstablishmentRegisterStrings.cloudOffIcon,
            width: 34,
            height: 34,
            colorFilter: const ColorFilter.mode(
              AppColors.error,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      title: EstablishmentRegisterStrings.offlineModalTitle,
      message: EstablishmentRegisterStrings.offlineModalMessage,
      content: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Column(
          children: [
            _ConnectivityRecommendation(
              title: EstablishmentRegisterStrings.offlineWifiTitle,
              subtitle: EstablishmentRegisterStrings.offlineWifiSubtitle,
            ),
            SizedBox(height: AppSpacing.sm),
            _ConnectivityRecommendation(
              title: EstablishmentRegisterStrings.offlineMobileDataTitle,
              subtitle: EstablishmentRegisterStrings.offlineMobileDataSubtitle,
            ),
          ],
        ),
      ),
      action: AppFilledButton(
        label: EstablishmentRegisterStrings.offlineRetryButton,
        icon: SvgPicture.asset(
          EstablishmentRegisterStrings.cachedIcon,
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

/// Opcion breve que sugiere una fuente de conexión para completar el alta.
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
            color: AppColors.onPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              EstablishmentRegisterStrings.cloudIcon,
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
