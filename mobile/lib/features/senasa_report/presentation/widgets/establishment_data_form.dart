import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';

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
    // Lista de prueba (Mocks) con RENSPAs reales simulados de Argentina
    final List<String> origenes = SenasaStrings.establishmentOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text(
            SenasaStrings.establishmentSectionTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        AppSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: DropdownButtonFormField<String>(
              isExpanded: true, // Evita desborde de píxeles horizontales
              value: selectedOrigen,
              decoration: const InputDecoration(
                labelText: SenasaStrings.establishmentSelectorLabel,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: origenes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis, // Recorta el RENSPA con ... si la pantalla es chica
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onOrigenChanged,
            ),
          ),
        ),
      ],
    );
  }
}
