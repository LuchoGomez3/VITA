import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';

/// Tarjeta que presenta todos los datos disponibles del usuario.
class ProfileUserCard extends StatelessWidget {
  /// Crea la tarjeta con la información de la sesión.
  const ProfileUserCard({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.cuit,
    super.key,
  });

  /// ID interno del usuario.
  final String userId;

  /// Correo electrónico de acceso.
  final String email;

  /// Nombre del usuario.
  final String firstName;

  /// Apellido del usuario.
  final String lastName;

  /// CUIT opcional.
  final String? cuit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ProfileStrings.userDataSection,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSurfaceCard(
          child: Column(
            children: [
              ProfileInfoRow(
                label: ProfileStrings.userIdLabel,
                value: userId,
                icon: Icons.fingerprint,
              ),
              const Divider(),
              ProfileInfoRow(
                label: ProfileStrings.emailLabel,
                value: email,
                icon: Icons.email_outlined,
              ),
              const Divider(),
              ProfileInfoRow(
                label: ProfileStrings.firstNameLabel,
                value: firstName,
                icon: Icons.badge_outlined,
              ),
              const Divider(),
              ProfileInfoRow(
                label: ProfileStrings.lastNameLabel,
                value: lastName,
                icon: Icons.badge_outlined,
              ),
              const Divider(),
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
      children: [
        Icon(icon, color: AppColors.primary),
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
