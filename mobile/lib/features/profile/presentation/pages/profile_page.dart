import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:frontend_mayoral/features/profile/presentation/mock/settings_mock.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_establishments_section.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_sliver_header.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_user_card.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/settings_row.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/settings_section_card.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// Callback que cierra la sesión actual.
typedef SignOut = Future<void> Function();

/// Factory que crea el Cubit responsable de los establecimientos de Perfil.
typedef ProfileCubitFactory = ProfileCubit Function();

/// Versión y número de compilación de la app instalada.
typedef AppVersion = ({String version, String buildNumber});

/// Lee la versión de la app instalada.
typedef AppVersionReader = Future<AppVersion> Function();

/// Pantalla que muestra el usuario y sus establecimientos.
class ProfilePage extends StatefulWidget {
  /// Crea la pantalla con los datos de la sesión autenticada.
  const ProfilePage({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.cuit,
    required this.createCubit,
    required this.signOut,
    required this.readAppVersion,
    super.key,
  });

  /// Correo usado para iniciar sesión.
  final String email;

  /// Nombre del usuario.
  final String firstName;

  /// Apellido del usuario.
  final String lastName;

  /// CUIT opcional del usuario.
  final String? cuit;

  /// Crea el Cubit perteneciente a esta página.
  final ProfileCubitFactory createCubit;

  /// Cierra la sesión actual.
  final SignOut signOut;

  /// Lee la versión instalada para la fila "Versión".
  final AppVersionReader readAppVersion;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => widget.createCubit()..load(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            ProfileSliverHeader(
              firstName: widget.firstName,
              lastName: widget.lastName,
            ),
            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileUserCard(
                            email: widget.email,
                            cuit: widget.cuit,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          const _EstablishmentsContent(),
                          const SizedBox(height: AppSpacing.xl),
                          _SettingsSections(readAppVersion: widget.readAppVersion),
                          const SizedBox(height: AppSpacing.lg),
                          AppFilledButton(
                            label: ProfileStrings.signOutButton,
                            loadingLabel: ProfileStrings.signingOutButton,
                            isLoading: _isSigningOut,
                            icon: const Icon(Icons.logout),
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.onError,
                            onPressed: _signOut,
                          ),
                        ],
                      ),
                    ),
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
      context.go(AppRoutes.signUp);
    }
  }
}

class _EstablishmentsContent extends StatelessWidget {
  const _EstablishmentsContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ResultState<List<EstablishmentDetails>>>(
      builder: (context, state) => switch (state) {
        Data<List<EstablishmentDetails>>(:final data) => ProfileEstablishmentsSection(
          establishments: data,
          onOpen: (establishment) => context.push(AppRoutes.profileEstablishment, extra: establishment),
          onJoin: () => _showComingSoon(context),
        ),
        ResultError<List<EstablishmentDetails>>(:final error) => Column(
          children: [
            Text(error.message),
            const SizedBox(height: AppSpacing.sm),
            AppOutlinedButton(
              label: ProfileStrings.retry,
              onPressed: context.read<ProfileCubit>().load,
            ),
          ],
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text(ProfileStrings.comingSoonMessage)));
}

/// Secciones de `AjustesScreen`: dispositivos, preferencias y "sobre la app".
/// Salvo la versión, todavía son datos de ejemplo (ver
/// `.claude/specs/ajustes.md`) y sus filas solo avisan que llegan pronto.
class _SettingsSections extends StatelessWidget {
  const _SettingsSections({required this.readAppVersion});

  final AppVersionReader readAppVersion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionCard(
          title: ProfileStrings.pairedDevicesSection,
          rows: [
            for (final device in pairedDevicesMock)
              SettingsRow(
                icon: device.icon,
                label: device.name,
                subtitle: device.detail,
                subtitleColor: device.isConnected ? AppColors.primary : null,
              ),
            SettingsRow(
              icon: Icons.add,
              label: ProfileStrings.addDeviceLabel,
              isPrimaryAction: true,
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SettingsSectionCard(
          title: ProfileStrings.preferencesSection,
          rows: [
            for (final item in preferencesMock)
              SettingsRow(
                icon: item.icon,
                label: item.label,
                subtitle: item.value,
                isNavigable: true,
                onTap: () => _showComingSoon(context),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SettingsSectionCard(
          title: ProfileStrings.aboutAppSection,
          rows: [
            for (final item in aboutAppMock)
              SettingsRow(
                icon: item.icon,
                label: item.label,
                subtitle: item.value,
                isNavigable: true,
                onTap: () => _showComingSoon(context),
              ),
            _VersionRow(readAppVersion: readAppVersion),
          ],
        ),
      ],
    );
  }
}

/// Fila "Versión" con la versión real instalada (no navegable).
class _VersionRow extends StatefulWidget {
  const _VersionRow({required this.readAppVersion});

  final AppVersionReader readAppVersion;

  @override
  State<_VersionRow> createState() => _VersionRowState();
}

class _VersionRowState extends State<_VersionRow> {
  static final _logger = Logger('ProfileVersionRow');

  late final Future<AppVersion?> _version = _read();

  Future<AppVersion?> _read() async {
    try {
      return await widget.readAppVersion();
    } on Exception catch (error, stackTrace) {
      // No es crítico: la fila queda con un guion en vez de la versión.
      _logger.warning('No se pudo leer la versión instalada', error, stackTrace);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppVersion?>(
      future: _version,
      builder: (context, snapshot) {
        final version = snapshot.data;
        return SettingsRow(
          icon: Icons.verified_user_outlined,
          label: ProfileStrings.versionLabel,
          subtitle: version == null
              ? ProfileStrings.emptyCredential
              : ProfileStrings.versionValue(version.version, version.buildNumber),
        );
      },
    );
  }
}
