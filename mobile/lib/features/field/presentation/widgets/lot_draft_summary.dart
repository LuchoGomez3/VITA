import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/presentation/bloc/lot_editor_bloc.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Resumen editable del nombre, vértices y superficie del borrador.
class LotDraftSummary extends StatefulWidget {
  /// Crea el resumen conectado al estado actual.
  const LotDraftSummary({
    required this.state,
    required this.onNameChanged,
    required this.onSurfaceChanged,
    super.key,
  });

  /// Estado actual del borrador.
  final LotEditorState state;

  /// Notifica cada cambio del nombre local.
  final ValueChanged<String> onNameChanged;

  /// Notifica cambios en la superficie declarada en hectáreas.
  final ValueChanged<String> onSurfaceChanged;

  @override
  State<LotDraftSummary> createState() => _LotDraftSummaryState();
}

class _LotDraftSummaryState extends State<LotDraftSummary> {
  late final TextEditingController _nameController;
  late final TextEditingController _surfaceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.draft.name);
    _surfaceController = TextEditingController(
      text: widget.state.draft.surfaceTenths > 0 ? (widget.state.draft.surfaceTenths / 10).toStringAsFixed(1) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surfaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextFormField(
          controller: _nameController,
          title: FieldStrings.lotNameLabel,
          hintText: FieldStrings.lotNameHint,
          textInputAction: TextInputAction.next,
          validation: widget.state.isClosed && widget.state.draft.name.trim().isEmpty
              ? AppFieldValidation.invalid
              : AppFieldValidation.neutral,
          validationMessage: widget.state.isClosed && widget.state.draft.name.trim().isEmpty
              ? FieldStrings.requiredLotNameError
              : null,
          onChanged: widget.onNameChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextFormField(
          controller: _surfaceController,
          title: FieldStrings.surfaceHectaresLabel,
          hintText: FieldStrings.surfaceHectaresHint,
          helperText: FieldStrings.surfaceHectaresHelper,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9,.]')),
          ],
          validation: widget.state.isClosed && widget.state.draft.surfaceTenths <= 0
              ? AppFieldValidation.invalid
              : AppFieldValidation.neutral,
          validationMessage: widget.state.isClosed && widget.state.draft.surfaceTenths <= 0
              ? FieldStrings.requiredSurfaceError
              : null,
          onChanged: widget.onSurfaceChanged,
        ),
      ],
    );
  }
}
