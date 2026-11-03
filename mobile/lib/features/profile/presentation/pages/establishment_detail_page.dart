import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/boundary_point.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/services/field_boundary_geometry.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/widgets/location_map_preview.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/establishment_details_grid.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/settings_row.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/settings_section_card.dart';
import 'package:go_router/go_router.dart';

/// Ficha de un establecimiento: el campo en el mapa satelital, la superficie y
/// los datos de identificación.
///
/// Los datos salen del catálogo guardado en el celular, así que se ve sin conexión;
/// sin señal el mapa queda con el pin y el contorno sobre fondo liso.
class EstablishmentDetailPage extends StatelessWidget {
  /// Crea la ficha de [establishment].
  const EstablishmentDetailPage({
    required this.establishment,
    super.key,
    this.showSatelliteImagery = true,
    this.onOpenTeam,
  });

  /// Establecimiento a mostrar.
  final EstablishmentDetails establishment;

  /// Si se pide la imagen satelital. Los tests lo apagan para no usar la red.
  final bool showSatelliteImagery;

  /// Abre el equipo del establecimiento; por defecto navega a su ruta.
  final VoidCallback? onOpenTeam;

  @override
  Widget build(BuildContext context) {
    final boundary = [
      for (final point in establishment.boundary) BoundaryPoint(latitud: point.latitude, longitud: point.longitude),
    ];
    final hasBoundary = boundary.length >= 3;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        centerTitle: true,
        title: Text(
          establishment.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.appBarTitle,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xl),
              children: [
                _FieldMap(
                  establishment: establishment,
                  boundary: boundary,
                  showSatelliteImagery: showSatelliteImagery,
                ),
                const SizedBox(height: AppSpacing.md),
                _Identity(establishment: establishment),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _AreaTile(
                        label: ProfileStrings.declaredAreaLabel,
                        value: _hectaresOrEmpty(establishment.areaHectares),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _AreaTile(
                        label: ProfileStrings.mappedAreaLabel,
                        value: hasBoundary
                            ? ProfileStrings.hectares(FieldBoundaryGeometry.areaHectares(boundary))
                            : ProfileStrings.boundaryMissing,
                        isMuted: !hasBoundary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(ProfileStrings.establishmentDataSection, style: AppTypography.pageTitle),
                const SizedBox(height: AppSpacing.sm),
                AppSurfaceCard(
                  elevation: 0,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: EstablishmentDetailsGrid(
                    fields: [
                      (label: ProfileStrings.renspaLabel, value: _valueOrEmpty(establishment.renspaNumber)),
                      (label: ProfileStrings.cuitLabel, value: _valueOrEmpty(establishment.cuit)),
                      (label: ProfileStrings.provinceLabel, value: _valueOrEmpty(establishment.province)),
                      (label: ProfileStrings.departmentLabel, value: _valueOrEmpty(establishment.department)),
                      (label: ProfileStrings.localityLabel, value: _valueOrEmpty(establishment.locality)),
                      (label: ProfileStrings.coordinatesLabel, value: _coordinates(establishment)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsSectionCard(
                  title: ProfileStrings.teamSection,
                  rows: [
                    SettingsRow(
                      icon: Icons.group_outlined,
                      label: ProfileStrings.teamRowLabel,
                      subtitle: establishment.role.canManageTeam
                          ? ProfileStrings.teamRowManageSubtitle
                          : ProfileStrings.teamRowViewSubtitle,
                      isNavigable: true,
                      onTap: onOpenTeam ?? () => context.push(AppRoutes.teamFor(establishment.id)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _hectaresOrEmpty(double? area) =>
      area == null ? ProfileStrings.emptyCredential : ProfileStrings.hectares(area);

  static String _valueOrEmpty(String? value) =>
      value == null || value.trim().isEmpty ? ProfileStrings.emptyCredential : value;

  static String _coordinates(EstablishmentDetails establishment) {
    final latitude = establishment.latitude;
    final longitude = establishment.longitude;
    if (latitude == null || longitude == null) {
      return ProfileStrings.emptyCredential;
    }
    return ProfileStrings.coordinates(latitude, longitude);
  }
}

/// Mapa con el pin y el contorno, o un aviso si no hay ubicación.
class _FieldMap extends StatelessWidget {
  const _FieldMap({
    required this.establishment,
    required this.boundary,
    required this.showSatelliteImagery,
  });

  static const _height = 220.0;

  final EstablishmentDetails establishment;
  final List<BoundaryPoint> boundary;
  final bool showSatelliteImagery;

  @override
  Widget build(BuildContext context) {
    final latitude = establishment.latitude;
    final longitude = establishment.longitude;
    if (latitude == null || longitude == null) {
      return Container(
        height: _height,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 32, color: AppColors.textHint),
            SizedBox(height: AppSpacing.xs),
            Text(ProfileStrings.noLocation, style: AppTypography.mediumEmphasis),
            SizedBox(height: AppSpacing.xxs),
            Text(ProfileStrings.noLocationHint, style: AppTypography.formFieldHelper, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final hasBoundary = boundary.length >= 3;
    return Stack(
      children: [
        LocationMapPreview(
          latitud: latitude,
          longitud: longitude,
          boundary: boundary,
          height: _height,
          showSatelliteImagery: showSatelliteImagery,
        ),
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: AppStatusChip(
            label: hasBoundary ? ProfileStrings.boundaryDrawn : ProfileStrings.boundaryMissing,
            tone: hasBoundary ? AppStatusChipTone.success : AppStatusChipTone.neutral,
            showDot: true,
          ),
        ),
      ],
    );
  }
}

/// Rol del usuario y localidad, debajo del mapa.
class _Identity extends StatelessWidget {
  const _Identity({required this.establishment});

  final EstablishmentDetails establishment;

  @override
  Widget build(BuildContext context) {
    final place = [
      establishment.locality,
      establishment.province,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');

    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: AppColors.backgroundSecondaryLight,
          child: Icon(Icons.agriculture_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(establishment.name, style: AppTypography.formFieldValueEmphasis),
              if (place.isNotEmpty) Text(place, style: AppTypography.formFieldHelper),
            ],
          ),
        ),
        AppStatusChip(label: UserRoleStrings.name(establishment.role), tone: AppStatusChipTone.success),
      ],
    );
  }
}

/// Tarjeta chica con una superficie.
class _AreaTile extends StatelessWidget {
  const _AreaTile({required this.label, required this.value, this.isMuted = false});

  final String label;
  final String value;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      elevation: 0,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.formFieldHelper),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTypography.pageTitle.copyWith(
              fontSize: 20,
              color: isMuted ? AppColors.textHint : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
