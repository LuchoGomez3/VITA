import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/fields/fields.dart'; // Asumo que acá está exportado AppChoiceSelector

//Strings
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

class EventTypeSelector extends StatelessWidget {
  final String selectedMovement;
  final ValueChanged<String> onChanged;

  const EventTypeSelector({
    super.key,
    required this.selectedMovement,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<AppChoiceOption<String>> movementTypes = SenasaStrings.eventTypes
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
