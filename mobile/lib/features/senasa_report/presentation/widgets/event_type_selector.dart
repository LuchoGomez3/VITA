import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/fields/fields.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

/// Selector del tipo de evento incluido en el reporte SENASA.
class EventTypeSelector extends StatelessWidget {
  /// Crea el selector con el evento actual y su callback de cambio.
  const EventTypeSelector({
    required this.selectedMovement,
    required this.onChanged,
    super.key,
  });

  /// Tipo de evento actualmente seleccionado.
  final String selectedMovement;

  /// Notifica el nuevo tipo de evento seleccionado.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final movementTypes = SenasaStrings.eventTypes
        .map((type) => AppChoiceOption<String>(value: type, label: type))
        .toList();

    return AppChoiceSelector<String>(
      title: SenasaStrings.eventSelectorTitle,
      titleStyle: AppTypography.pageTitle,
      options: movementTypes,
      value: selectedMovement,
      onChanged: onChanged,
    );
  }
}
