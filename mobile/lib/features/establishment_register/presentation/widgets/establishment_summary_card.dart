import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

/// Tarjeta resumen del establecimiento recién creado, en la pantalla de éxito.
class EstablishmentSummaryCard extends StatelessWidget {
  /// Crea la tarjeta resumen a partir del establecimiento registrado.
  const EstablishmentSummaryCard({required this.registeredEstablishment, super.key});

  /// Establecimiento devuelto por el flujo de alta.
  final RegisteredEstablishment registeredEstablishment;

  @override
  Widget build(BuildContext context) {
    final registration = registeredEstablishment.registration;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(registration.nombre, style: AppTypography.pageTitle),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${EstablishmentRegisterStrings.reviewRenspaLabel} ${registration.nroRenspa}',
                      style: AppTypography.monoValue.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '${registration.localidad}, ${registration.provincia}',
                          style: AppTypography.formFieldHelper,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  EstablishmentRegisterStrings.successOwnerChipLabel,
                  style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppInfoCell(
                  label: EstablishmentRegisterStrings.successSurfaceStatLabel,
                  value: '${registration.superficieHectareas.toStringAsFixed(0)} ha',
                ),
              ),
              const Expanded(
                child: AppInfoCell(
                  label: EstablishmentRegisterStrings.successAnimalsStatLabel,
                  value: '0',
                ),
              ),
              const Expanded(
                child: AppInfoCell(
                  label: EstablishmentRegisterStrings.successProductionUnitsStatLabel,
                  value: '1',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
