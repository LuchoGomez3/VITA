import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/presentation/cubit/profile_appearance_cubit.dart';
import 'package:frontend_mayoral/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:frontend_mayoral/features/profile/presentation/mock/settings_mock.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_appearance_sheet.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_establishments_section.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_sliver_header.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_user_card.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/settings_row.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/settings_section_card.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/toon_head_avatar_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';

/// Callback que cierra la sesión actual.
typedef SignOut = Future<void> Function();

/// Factory que crea el Cubit responsable de los establecimientos de Perfil.
typedef ProfileCubitFactory = ProfileCubit Function();

/// Factory del Cubit de la foto y el color de la cabecera de [userId].
typedef ProfileAppearanceCubitFactory = ProfileAppearanceCubit Function(String userId);

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
    required this.userId,
    required this.createAppearanceCubit,
    super.key,
  });

  /// Usuario de la sesión; sin sesión restaurada no se puede editar la
  /// cabecera.
  final String? userId;

  /// Crea el Cubit de la foto y el color.
  final ProfileAppearanceCubitFactory createAppearanceCubit;

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
    final userId = widget.userId;
    final content = Scaffold(
      body: CustomScrollView(
        slivers: [
          if (userId == null)
            ProfileSliverHeader(firstName: widget.firstName, lastName: widget.lastName)
          else
            _AppearanceHeader(firstName: widget.firstName, lastName: widget.lastName),
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
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(create: (_) => widget.createCubit()..load()),
        if (userId != null)
          BlocProvider<ProfileAppearanceCubit>(create: (_) => widget.createAppearanceCubit(userId)..start()),
      ],
      child: content,
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
          onJoin: () async {
            await context.push<void>(AppRoutes.joinEstablishment);
            // Se recarga siempre: "Ir al inicio" sale con `go` y no devuelve nada.
            if (context.mounted) {
              await context.read<ProfileCubit>().load();
            }
          },
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

/// Cabecera con el color y la foto del usuario, y el lápiz para cambiarlos.
class _AppearanceHeader extends StatelessWidget {
  const _AppearanceHeader({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;

  static final _logger = Logger('ProfileAppearance');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileAppearanceCubit, ProfileAppearanceState>(
      listenWhen: (previous, current) =>
          current.notice != previous.notice || current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        final message =
            state.errorMessage ??
            switch (state.notice) {
              ProfileAppearanceNotice.saved => ProfileStrings.appearanceSaved,
              ProfileAppearanceNotice.savedOffline => ProfileStrings.appearanceSavedOffline,
              null => null,
            };
        if (message == null) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        context.read<ProfileAppearanceCubit>().clearMessages();
      },
      builder: (context, state) {
        final appearance = state.appearance;
        final color = appearance.headerColor;
        final avatarPath = appearance.avatarPath;
        return ProfileSliverHeader(
          firstName: firstName,
          lastName: lastName,
          headerColor: color == null ? null : Color(color),
          avatar: avatarPath == null ? null : FileImage(File(avatarPath)),
          onEdit: state.isSaving ? null : () => _edit(context, appearance.headerColor, avatarPath != null),
        );
      },
    );
  }

  Future<void> _edit(BuildContext context, int? currentColor, bool hasPhoto) async {
    final cubit = context.read<ProfileAppearanceCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showProfileAppearanceSheet(context, currentColor: currentColor, hasPhoto: hasPhoto);
    switch (choice) {
      case null:
        return;
      case HeaderColorChoice(:final color):
        await cubit.changeHeaderColor(color);
      case RemovePhotoChoice():
        await cubit.removeAvatar();
      case TakePhotoChoice():
        await _pick(cubit, messenger, ImageSource.camera);
      case PickPhotoChoice():
        await _pick(cubit, messenger, ImageSource.gallery);
      case ChooseAvatarChoice():
        if (!context.mounted) {
          return;
        }
        final seed = await showToonHeadAvatarPicker(context);
        if (seed != null) {
          await cubit.changeAvatar(await ToonHeadAvatars.toPng(ToonHeadAvatars.svg(seed)));
        }
    }
  }

  Future<void> _pick(ProfileAppearanceCubit cubit, ScaffoldMessengerState messenger, ImageSource source) async {
    try {
      // Achicada en el celular para que suba rápido con poca señal; el
      // backend la deja en 512 px igual.
      final photo = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
        requestFullMetadata: false,
      );
      if (photo != null) {
        await cubit.changeAvatar(await photo.readAsBytes());
      }
    } on PlatformException catch (error, stackTrace) {
      _logger.warning('No se pudo abrir la cámara o la galería', error, stackTrace);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text(ProfileStrings.photoPickerError)));
    }
  }
}
