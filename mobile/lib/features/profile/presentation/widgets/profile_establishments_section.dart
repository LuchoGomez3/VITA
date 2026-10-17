import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/settings_row.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/settings_section_card.dart';

/// Sección que presenta todos los establecimientos de la sesión.
///
/// Es una lista como `SectionList` del diseño: cada fila abre la ficha del
/// establecimiento y la última permite sumarse a otro.
class ProfileEstablishmentsSection extends StatelessWidget {
  /// Crea la sección con el catálogo offline.
  const ProfileEstablishmentsSection({
    required this.establishments,
    required this.onOpen,
    required this.onJoin,
    super.key,
  });

  /// Catálogo completo disponible offline.
  final List<EstablishmentDetails> establishments;

  /// Abre la ficha del establecimiento tocado.
  final ValueChanged<EstablishmentDetails> onOpen;

  /// Acción "Sumarme a otro establecimiento".
  final VoidCallback onJoin;

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
        SettingsSectionCard(
          rows: [
            if (establishments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(ProfileStrings.noEstablishments),
              ),
            for (final establishment in establishments)
              SettingsRow(
                icon: Icons.agriculture_outlined,
                label: establishment.name,
                subtitle: _summary(establishment),
                isNavigable: true,
                onTap: () => onOpen(establishment),
              ),
            SettingsRow(
              icon: Icons.add,
              label: ProfileStrings.joinEstablishmentLabel,
              isPrimaryAction: true,
              onTap: onJoin,
            ),
          ],
        ),
      ],
    );
  }

  /// "Dueño · 847 ha": el rol y, si se conoce, la superficie declarada.
  String _summary(EstablishmentDetails establishment) {
    final area = establishment.areaHectares;
    return [
      UserRoleStrings.name(establishment.role),
      if (area != null) ProfileStrings.hectares(area),
    ].join(' · ');
  }
}
