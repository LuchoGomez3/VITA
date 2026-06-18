import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

//Strings
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

class EventTypeSelector extends StatelessWidget {
  // Recibe el valor actual y una función para avisar que cambió
  final String selectedMovement;
  final ValueChanged<String> onChanged;

  const EventTypeSelector({
    super.key,
    required this.selectedMovement,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> movementTypes = SenasaStrings.eventTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text(
            SenasaStrings.eventSelectorTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 /*, color: Colors.black87*/),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 10.0,
          children: movementTypes.map((type) {
            final isSelected = selectedMovement == type;
            return InkWell(
              // ¡Acá disparamos la función hacia la pantalla principal!
              onTap: () => onChanged(type),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
