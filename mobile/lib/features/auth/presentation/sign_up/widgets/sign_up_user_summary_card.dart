import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/strings/sign_up_strings.dart';

/// Resumen de identidad y rol de la cuenta creada.
class SignUpUserSummaryCard extends StatelessWidget {
  /// Crea la tarjeta con los datos no sensibles del usuario.
  const SignUpUserSummaryCard({required this.userData, super.key});

  /// Usuario registrado que se muestra en el resumen.
  final AppUser userData;

  @override
  Widget build(BuildContext context) {
    final fullName = '${userData.firstName} ${userData.lastName}'.trim();
    final firstInitial = userData.firstName.trim().isEmpty ? '' : userData.firstName.trim()[0];
    final lastInitial = userData.lastName.trim().isEmpty ? '' : userData.lastName.trim()[0];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              '$firstInitial$lastInitial'.toUpperCase(),
              style: AppTypography.avatarInitials,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: AppTypography.formFieldValueEmphasis,
                ),
                Text(userData.email, style: AppTypography.formFieldHelper),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Text(
                        SignUpStrings.ownerRole,
                        style: AppTypography.formFieldSuccess,
                      ),
                    ),
                    Text(
                      '${SignUpStrings.successCuitLabel}  ${userData.cuit ?? ''}',
                      style: AppTypography.smallEmphasis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
