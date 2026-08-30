import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Seleccion validada por el formulario de movimiento de animales.
class LotMovementInput {
  /// Crea los datos que la page enviara al Cubit.
  const LotMovementInput({
    required this.animalIds,
    required this.destinationLotId,
    required this.occurredAt,
    required this.reason,
  });

  /// Animales seleccionados para el movimiento.
  final List<String> animalIds;

  /// Lote activo elegido como destino.
  final String destinationLotId;

  /// Fecha efectiva del movimiento.
  final DateTime occurredAt;

  /// Motivo ingresado por el usuario.
  final String reason;
}

/// Formulario modal para seleccionar y mover animales entre lotes.
class LotMovementDialog extends StatefulWidget {
  /// Crea el formulario con animales y destinos disponibles.
  const LotMovementDialog({
    required this.animals,
    required this.destinations,
    super.key,
  });

  /// Animales presentes en el lote de origen.
  final List<LotAnimalSummary> animals;

  /// Lotes activos habilitados como destino.
  final List<Lot> destinations;

  @override
  State<LotMovementDialog> createState() => _LotMovementDialogState();
}

class _LotMovementDialogState extends State<LotMovementDialog> {
  final _selectedAnimalIds = <String>{};
  final _reasonController = TextEditingController();
  String? _destinationLotId;
  DateTime _occurredAt = DateTime.now();
  String? _validationMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(FieldStrings.moveAnimalsTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdownFormField<String>(
              title: FieldStrings.destinationLotLabel,
              hintText: FieldStrings.destinationLotLabel,
              initialValue: _destinationLotId,
              options: [
                for (final lot in widget.destinations) AppDropdownOption(value: lot.id, label: lot.name),
              ],
              onChanged: (value) => _destinationLotId = value,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(FieldStrings.animalsSectionTitle(widget.animals.length)),
            for (final animal in widget.animals)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _selectedAnimalIds.contains(animal.id),
                title: Text(
                  animal.visualTag.isEmpty ? animal.rfidTagNumber : animal.visualTag,
                ),
                onChanged: (selected) => setState(() {
                  if (selected ?? false) {
                    _selectedAnimalIds.add(animal.id);
                  } else {
                    _selectedAnimalIds.remove(animal.id);
                  }
                }),
              ),
            const SizedBox(height: AppSpacing.sm),
            AppTextFormField(
              controller: _reasonController,
              title: FieldStrings.movementReasonLabel,
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                '${FieldStrings.movementDateLabel}: '
                '${_formatDate(_occurredAt)}',
              ),
            ),
            if (_validationMessage case final message?) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message, style: AppTypography.errorBody),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(FieldStrings.cancelClearBoundaryCta),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(FieldStrings.moveAnimalsCta),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected != null) setState(() => _occurredAt = selected);
  }

  void _submit() {
    if (_selectedAnimalIds.isEmpty || _destinationLotId == null || _reasonController.text.trim().isEmpty) {
      setState(() => _validationMessage = FieldStrings.invalidMovementError);
      return;
    }
    Navigator.pop(
      context,
      LotMovementInput(
        animalIds: _selectedAnimalIds.toList(growable: false),
        destinationLotId: _destinationLotId!,
        occurredAt: _occurredAt,
        reason: _reasonController.text.trim(),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
