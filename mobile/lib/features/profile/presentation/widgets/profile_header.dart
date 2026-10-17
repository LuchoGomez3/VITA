import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';

/// Encabezado del perfil que reúne el título y la identidad de la cuenta.
class ProfileHeader extends StatelessWidget {
  /// Crea la cabecera con el nombre y apellido de la sesión.
  const ProfileHeader({required this.firstName, required this.lastName, this.showTitle = true, super.key});

  /// Permite que la cabecera desplazable dibuje el título en una capa fija.
  final bool showTitle;

  /// Nombre mostrado junto al apellido.
  final String firstName;

  /// Apellido mostrado en la identidad de la cuenta.
  final String lastName;

  @override
  Widget build(BuildContext context) {
    // Characters conserva letras con acentos y otros grafemas completos.
    final names = [firstName.trim(), lastName.trim()].where((name) => name.isNotEmpty);
    final initials = names.map((name) => name.characters.first).join();
    final fullName = names.join(' ');

    return Padding(
      // El margen inferior deja el subtítulo dentro del centro de la elipse.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Visibility(
              visible: showTitle,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Text(
                ProfileStrings.title,
                style: AppTypography.appBarTitle.copyWith(color: AppColors.onPrimary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.onPrimary.withValues(alpha: 0.16),
                child: initials.isEmpty
                    ? const Icon(Icons.person_outline, color: AppColors.onPrimary, size: 32)
                    : Text(
                        initials.toUpperCase(),
                        style: AppTypography.bigTitle.copyWith(color: AppColors.onPrimary),
                      ),
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
      ),
    );
  }
}
