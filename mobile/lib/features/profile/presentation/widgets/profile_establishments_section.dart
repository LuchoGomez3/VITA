import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_user_card.dart';

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
        Text(
          ProfileStrings.establishmentsSection,
          style: Theme.of(context).textTheme.titleLarge,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            establishment.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileInfoRow(
            label: ProfileStrings.renspaLabel,
            value: _value(establishment.renspaNumber),
            icon: Icons.assignment_outlined,
          ),
          const Divider(),
          ProfileInfoRow(
            label: ProfileStrings.cuitLabel,
            value: _value(establishment.cuit),
            icon: Icons.numbers,
          ),
          const Divider(),
          ProfileInfoRow(
            label: ProfileStrings.areaLabel,
            value: _area(establishment.areaHectares),
            icon: Icons.landscape_outlined,
          ),
          const Divider(),
          ProfileInfoRow(
            label: ProfileStrings.provinceLabel,
            value: _value(establishment.province),
            icon: Icons.map_outlined,
          ),
          const Divider(),
          ProfileInfoRow(
            label: ProfileStrings.departmentLabel,
            value: _value(establishment.department),
            icon: Icons.location_city_outlined,
          ),
          const Divider(),
          ProfileInfoRow(
            label: ProfileStrings.localityLabel,
            value: _value(establishment.locality),
            icon: Icons.place_outlined,
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
    return value == null || value.trim().isEmpty
        ? ProfileStrings.emptyCredential
        : value;
  }
}
