import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

/// Encabezado superior de la pantalla de estado vacío: usuario actual + salir.
class EstablishmentEmptyStateHeader extends StatelessWidget {
  /// Crea el encabezado con el callback de cierre de sesion.
  const EstablishmentEmptyStateHeader({required this.onSignOut, super.key});

  /// Cierra la sesion actual.
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.xxs),
              Text(
                EstablishmentRegisterStrings.emptyStateUserName,
                style: AppTypography.smallEmphasis,
              ),
            ],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onSignOut,
          child: Text(
            EstablishmentRegisterStrings.emptyStateSignOut,
            style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
