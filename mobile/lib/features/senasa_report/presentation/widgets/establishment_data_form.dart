import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart'; // Acá debería estar exportado el AppDropdownFormField
import 'package:frontend_mayoral/core/theme/theme.dart';

//Strings
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

class EstablishmentSelector extends StatelessWidget {
  final String? selectedOrigen;
  final ValueChanged<String?> onOrigenChanged;

  const EstablishmentSelector({
    super.key,
    required this.selectedOrigen,
    required this.onOrigenChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Convertimos la lista de Strings en una lista de AppDropdownOption
    final List<AppDropdownOption<String>> dropdownOptions = SenasaStrings.establishmentOptions
        .map((e) => AppDropdownOption<String>(value: e, label: e))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.xxs),
          child: Text(
            SenasaStrings.establishmentSectionTitle,
            style: AppTypography.pageTitle,
          ),
        ),
        AppSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxs),
            child: AppDropdownFormField<String>(
              // 2. Usamos el componente del Core
              hintText: SenasaStrings.establishmentSelectorLabel,
              initialValue: selectedOrigen,
              options: dropdownOptions,
              onChanged: onOrigenChanged,
            ),
          ),
        ),
      ],
    );
  }
}
