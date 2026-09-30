import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';

/// Tarjeta que presenta los datos personales del usuario.
class ProfileUserCard extends StatelessWidget {
  /// Crea la tarjeta con la información de la sesión.
  const ProfileUserCard({
    required this.email,
    required this.cuit,
    super.key,
  });

  /// Correo electrónico de acceso.
  final String email;

  /// CUIT opcional.
  final String? cuit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          ProfileStrings.userDataSection,
          style: AppTypography.pageTitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          elevation: 0,
          child: Column(
            children: [
              ProfileInfoRow(
                label: ProfileStrings.emailLabel,
                value: email,
                icon: Icons.email_outlined,
              ),
              const Divider(height: AppSpacing.lg),
              ProfileInfoRow(
                label: ProfileStrings.cuitLabel,
                value: cuit ?? ProfileStrings.emptyCredential,
                icon: Icons.numbers,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila común para representar un dato etiquetado.
class ProfileInfoRow extends StatelessWidget {
  /// Crea una fila con icono, etiqueta y valor.
  const ProfileInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  /// Etiqueta descriptiva del dato.
  final String label;

  /// Valor visible.
  final String value;

  /// Icono asociado al tipo de dato.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.termsBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.smallEmphasis),
              const SizedBox(height: AppSpacing.xs),
              SelectableText(value, style: AppTypography.formFieldValue),
            ],
          ),
        ),
      ],
    );
  }
}
