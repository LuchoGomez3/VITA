import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:go_router/go_router.dart';

/// Callback que cierra la sesion actual.
typedef SignOut = Future<void> Function();

/// Pantalla que muestra las credenciales del usuario y las acciones de cuenta.
class ProfilePage extends StatefulWidget {
  /// Crea la pantalla con los datos de la sesion autenticada.
  const ProfilePage({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.signOut,
    super.key,
  });

  /// Identificador utilizado por el usuario para iniciar sesion.
  final String username;

  /// Nombre del usuario autenticado.
  final String firstName;

  /// Apellido del usuario autenticado.
  final String lastName;

  /// Cierra la sesion autenticada.
  final SignOut signOut;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: ProfileStrings.title),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      _CredentialRow(
                        label: ProfileStrings.usernameLabel,
                        value: widget.username,
                        icon: Icons.person_outline,
                      ),
                      const Divider(),
                      _CredentialRow(
                        label: ProfileStrings.firstNameLabel,
                        value: widget.firstName,
                        icon: Icons.badge_outlined,
                      ),
                      const Divider(),
                      _CredentialRow(
                        label: ProfileStrings.lastNameLabel,
                        value: widget.lastName,
                        icon: Icons.badge_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AppFilledButton(
                    label: ProfileStrings.signOutButton,
                    loadingLabel: ProfileStrings.signingOutButton,
                    isLoading: _isSigningOut,
                    icon: const Icon(Icons.logout),
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    onPressed: _signOut,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    await widget.signOut();

    if (mounted) {
      context.go(AppRoutes.login);
    }
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
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
              Text(value, style: AppTypography.formFieldValue),
            ],
          ),
        ),
      ],
    );
  }
}
