import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/establishment_summary_card.dart';
import 'package:go_router/go_router.dart';

/// Pantalla final de confirmación del alta de establecimiento.
class EstablishmentRegisterSuccessPage extends StatelessWidget {
  /// Crea la pantalla de éxito con el establecimiento registrado.
  const EstablishmentRegisterSuccessPage({
    required this.registeredEstablishment,
    super.key,
  });

  /// Establecimiento devuelto por el flujo de alta.
  final RegisteredEstablishment registeredEstablishment;

  @override
  Widget build(BuildContext context) {
    final registration = registeredEstablishment.registration;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              const _SuccessCheck(),
              const SizedBox(height: AppSpacing.md),
              const Text(
                EstablishmentRegisterStrings.successTitle,
                style: AppTypography.bigTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${registration.nombre}${EstablishmentRegisterStrings.successSubtitleSuffix}',
                style: AppTypography.secondaryEmphasis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              EstablishmentSummaryCard(registeredEstablishment: registeredEstablishment),
              const SizedBox(height: AppSpacing.lg),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  EstablishmentRegisterStrings.successNextStepsTitle,
                  style: AppTypography.secondaryEmphasis,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const _NextStepRow(
                icon: Icons.grid_view_outlined,
                label: EstablishmentRegisterStrings.successNextStepDivideLabel,
                subtitle: EstablishmentRegisterStrings.successNextStepDivideSub,
              ),
              const SizedBox(height: AppSpacing.xs),
              const _NextStepRow(
                icon: Icons.group_outlined,
                label: EstablishmentRegisterStrings.successNextStepInviteLabel,
                subtitle: EstablishmentRegisterStrings.successNextStepInviteSub,
              ),
              const SizedBox(height: AppSpacing.xs),
              const _NextStepRow(
                icon: Icons.pets_outlined,
                label: EstablishmentRegisterStrings.successNextStepAnimalLabel,
                subtitle: EstablishmentRegisterStrings.successNextStepAnimalSub,
              ),
              const Spacer(flex: 2),
              AppOutlinedButton(
                label: EstablishmentRegisterStrings.successGoHomeButton,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessCheck extends StatelessWidget {
  const _SuccessCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 4),
      ),
      child: const Icon(Icons.check, color: AppColors.primary, size: 56),
    );
  }
}

class _NextStepRow extends StatelessWidget {
  const _NextStepRow({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // TODO(lucho): navegar a la funcionalidad sugerida cuando exista.
      onTap: () {},
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.mediumEmphasis.copyWith(color: AppColors.textPrimary),
                  ),
                  Text(subtitle, style: AppTypography.formFieldHelper),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
