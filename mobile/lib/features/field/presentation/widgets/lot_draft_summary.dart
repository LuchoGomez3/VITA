import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/presentation/bloc/lot_editor_bloc.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Resumen editable del nombre, vértices y superficie del borrador.
class LotDraftSummary extends StatelessWidget {
  /// Crea el resumen conectado al estado actual.
  const LotDraftSummary({
    required this.state,
    required this.onNameChanged,
    super.key,
  });

  /// Estado actual del borrador.
  final LotEditorState state;

  /// Notifica cada cambio del nombre local.
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: FieldStrings.lotVerticesLabel,
                value: '${state.vertices.length}',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _Metric(
                label: FieldStrings.lotAreaLabel,
                value: _formatArea(
                  state.validation.estimatedAreaSquareUnits,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: state.draft.name,
          onChanged: onNameChanged,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: FieldStrings.lotNameLabel,
            hintText: FieldStrings.lotNameHint,
            errorText: state.isClosed && state.draft.name.trim().isEmpty ? FieldStrings.requiredLotNameError : null,
          ),
        ),
      ],
    );
  }

  String _formatArea(double squareUnits) => '${squareUnits.toStringAsFixed(0)} ${FieldStrings.relativeAreaUnit}';
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.termsBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.smallEmphasis),
            const SizedBox(height: AppSpacing.xxs),
            Text(value, style: AppTypography.formFieldValueEmphasis),
          ],
        ),
      ),
    );
  }
}
