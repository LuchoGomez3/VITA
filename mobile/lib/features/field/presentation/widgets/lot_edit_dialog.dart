import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/forage_resource.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_surface.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Datos alfanumericos validados por el formulario de edicion.
class LotEditInput {
  /// Crea los datos que la page enviara al Cubit.
  const LotEditInput({
    required this.name,
    required this.surfaceTenths,
    required this.hasWater,
    required this.status,
    this.forageResourceCode,
  });

  /// Nombre normalizado del lote.
  final String name;

  /// Superficie expresada en decimas de hectarea.
  final int surfaceTenths;

  /// Codigo del recurso forrajero seleccionado.
  final String? forageResourceCode;

  /// Disponibilidad actual de agua.
  final bool hasWater;

  /// Estado operativo elegido.
  final LotStatus status;
}

/// Formulario modal para editar los datos mutables de un lote.
class LotEditDialog extends StatefulWidget {
  /// Crea el formulario precargado con [lot].
  const LotEditDialog({required this.lot, super.key});

  /// Lote cuyos datos se editaran.
  final Lot lot;

  @override
  State<LotEditDialog> createState() => _LotEditDialogState();
}

class _LotEditDialogState extends State<LotEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _surfaceController;
  late String? _forageResourceCode;
  late bool _hasWater;
  late LotStatus _status;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lot.name);
    _surfaceController = TextEditingController(
      text: widget.lot.surfaceHectares.toStringAsFixed(1),
    );
    _forageResourceCode = widget.lot.forageResourceCode;
    _hasWater = widget.lot.hasWater;
    _status = widget.lot.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surfaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(FieldStrings.editLotTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextFormField(
              controller: _nameController,
              title: FieldStrings.lotNameLabel,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextFormField(
              controller: _surfaceController,
              title: FieldStrings.surfaceHectaresLabel,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdownFormField<String>(
              title: FieldStrings.forageResourceFieldLabel,
              hintText: FieldStrings.forageResourceHint,
              initialValue: _forageResourceCode,
              options: [
                for (final resource in InitialForageResources.values)
                  AppDropdownOption(
                    value: resource.code,
                    label: resource.displayName,
                  ),
              ],
              onChanged: (value) => _forageResourceCode = value,
            ),
            const SizedBox(height: AppSpacing.md),
            AppChoiceSelector<bool>(
              title: FieldStrings.waterAvailabilityLabel,
              value: _hasWater,
              options: const [
                AppChoiceOption(
                  value: true,
                  label: FieldStrings.waterAvailable,
                ),
                AppChoiceOption(
                  value: false,
                  label: FieldStrings.waterUnavailable,
                ),
              ],
              onChanged: (value) => setState(() => _hasWater = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdownFormField<LotStatus>(
              title: FieldStrings.lotStatusLabel,
              hintText: FieldStrings.lotStatusLabel,
              initialValue: _status,
              options: [
                for (final status in LotStatus.values)
                  if (status != LotStatus.unknown)
                    AppDropdownOption(
                      value: status,
                      label: FieldStrings.statusName(status),
                    ),
              ],
              onChanged: (value) {
                if (value != null) _status = value;
              },
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
          child: const Text(FieldStrings.saveChangesCta),
        ),
      ],
    );
  }

  void _submit() {
    final surface = LotSurface.tryParse(_surfaceController.text);
    if (_nameController.text.trim().isEmpty || surface == null) {
      setState(
        () => _validationMessage = FieldStrings.invalidLotDetailsError,
      );
      return;
    }
    Navigator.pop(
      context,
      LotEditInput(
        name: _nameController.text.trim(),
        surfaceTenths: surface.tenths,
        forageResourceCode: _forageResourceCode,
        hasWater: _hasWater,
        status: _status,
      ),
    );
  }
}
