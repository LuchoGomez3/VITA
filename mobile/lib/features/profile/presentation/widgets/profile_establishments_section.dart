import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';

/// Sección que presenta todos los establecimientos de la sesión.
class ProfileEstablishmentsSection extends StatelessWidget {
  /// Crea la sección con el catálogo offline.
  const ProfileEstablishmentsSection({
    required this.establishments,
    super.key,
  });

  /// Catálogo completo disponible offline.
  final List<EstablishmentDetails> establishments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                ProfileStrings.establishmentsSection,
                style: AppTypography.pageTitle,
              ),
            ),
            AppStatusChip(label: '${establishments.length}'),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        const Text(
          ProfileStrings.establishmentsSubtitle,
          style: AppTypography.formFieldHelper,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (establishments.isEmpty)
          const AppSurfaceCard(
            child: Text(ProfileStrings.noEstablishments),
          )
        else
          ...establishments.map(
            (establishment) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _EstablishmentCard(establishment: establishment),
            ),
          ),
      ],
    );
  }
}

class _EstablishmentCard extends StatelessWidget {
  const _EstablishmentCard({required this.establishment});

  final EstablishmentDetails establishment;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      elevation: 0,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      UserRoleStrings.name(establishment.role),
                      style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          _EstablishmentDetailsGrid(
            fields: [
              (label: ProfileStrings.renspaLabel, value: _value(establishment.renspaNumber)),
              (label: ProfileStrings.cuitLabel, value: _value(establishment.cuit)),
              (label: ProfileStrings.areaLabel, value: _area(establishment.areaHectares)),
              (label: ProfileStrings.provinceLabel, value: _value(establishment.province)),
              (label: ProfileStrings.departmentLabel, value: _value(establishment.department)),
              (label: ProfileStrings.localityLabel, value: _value(establishment.locality)),
            ],
          ),
        ],
      ),
    );
  }

  String _area(double? area) {
    if (area == null) {
      return ProfileStrings.emptyCredential;
    }
    return '${area.toStringAsFixed(2)} ${ProfileStrings.hectaresUnit}';
  }

  String _value(String? value) {
    return value == null || value.trim().isEmpty ? ProfileStrings.emptyCredential : value;
  }
}

/// Agrupa datos en dos columnas y usa una sola con poco espacio o texto grande.
/// Wrap permite que cada fila crezca sin recortar los valores largos.
class _EstablishmentDetailsGrid extends StatelessWidget {
  const _EstablishmentDetailsGrid({required this.fields});

  final List<({String label, String value})> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 280 || MediaQuery.textScalerOf(context).scale(16) > 24;
        final width = useSingleColumn ? constraints.maxWidth : (constraints.maxWidth - AppSpacing.md) / 2;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.lg,
          children: [
            for (final field in fields)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(field.label, style: AppTypography.formFieldHelper),
                    const SizedBox(height: AppSpacing.xxs),
                    SelectableText(field.value, style: AppTypography.formFieldValue),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
