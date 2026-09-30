import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';

/// Tarjeta que presenta la identidad y los datos personales del usuario.
class ProfileUserCard extends StatelessWidget {
  /// Crea la tarjeta con la información de la sesión.
  const ProfileUserCard({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.cuit,
    super.key,
  });

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
        _ProfileIdentity(firstName: firstName, lastName: lastName),
        const SizedBox(height: AppSpacing.lg),
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

/// Destaca la identidad sin depender de una foto ni de conexión a internet.
class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;

  @override
  Widget build(BuildContext context) {
    // Characters conserva letras con acentos y otros grafemas completos.
    final names = [firstName.trim(), lastName.trim()].where((name) => name.isNotEmpty);
    final initials = names.map((name) => name.characters.first).join();
    final fullName = names.join(' ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.passwordStrengthVeryStrong],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.onPrimary.withValues(alpha: 0.16),
            child: initials.isEmpty
                ? const Icon(Icons.person_outline, color: AppColors.onPrimary, size: 32)
                : Text(
                    initials.toUpperCase(),
                    style: AppTypography.bigTitle.copyWith(color: AppColors.onPrimary),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            fullName.isEmpty ? ProfileStrings.usernameLabel : fullName,
            textAlign: TextAlign.center,
            style: AppTypography.bigTitle.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ProfileStrings.accountSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.formFieldValue.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
