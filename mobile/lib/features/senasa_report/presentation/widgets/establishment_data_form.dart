import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/validators/validators.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

/// Establishment selector used by the SENASA report filters.
class EstablishmentSelector extends StatelessWidget {
  /// Creates the establishment selector.
  const EstablishmentSelector({
    required this.establishments,
    required this.selectedOrigin,
    required this.onOriginChanged,
    super.key,
  });

  /// Establishments available to the authenticated user.
  final List<SenasaEstablishment> establishments;

  /// Currently selected establishment.
  final String? selectedOrigin;

  /// Called when the selected establishment changes.
  final ValueChanged<String?> onOriginChanged;

  @override
  Widget build(BuildContext context) {
    final dropdownOptions = establishments
        .map(
          (establishment) => AppDropdownOption<String>(
            value: establishment.id,
            label: establishment.renspa == null
                ? establishment.name
                : '${establishment.name} (RENSPA: ${establishment.renspa})',
          ),
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xxs,
            bottom: AppSpacing.xxs,
          ),
          child: Text(
            SenasaStrings.establishmentSectionTitle,
            style: AppTypography.pageTitle,
          ),
        ),
        AppSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxs),
            child: AppDropdownFormField<String>(
              hintText: SenasaStrings.establishmentSelectorLabel,
              initialValue: selectedOrigin,
              options: dropdownOptions,
              validator: (value) => FormValidators.requiredField(
                value,
                message: SenasaStrings.establishmentRequired,
              ),
              onChanged: onOriginChanged,
            ),
          ),
        ),
      ],
    );
  }
}
