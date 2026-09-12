import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary_validation.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Mensaje localizado para el primer problema geométrico del borrador.
class LotValidationMessage extends StatelessWidget {
  /// Crea el mensaje desde un error de dominio tipado.
  const LotValidationMessage({required this.issue, super.key});

  /// Problema geométrico que debe explicarse al usuario.
  final LotBoundaryValidationIssue issue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(_message(issue), style: AppTypography.errorBody),
            ),
          ],
        ),
      ),
    );
  }

  String _message(LotBoundaryValidationIssue value) {
    return switch (value) {
      LotBoundaryValidationIssue.insufficientVertices => FieldStrings.insufficientVerticesError,
      LotBoundaryValidationIssue.invalidCoordinate => FieldStrings.invalidCoordinateError,
      LotBoundaryValidationIssue.duplicateVertex => FieldStrings.duplicateVertexError,
      LotBoundaryValidationIssue.zeroArea => FieldStrings.zeroAreaError,
      LotBoundaryValidationIssue.selfIntersection => FieldStrings.selfIntersectionError,
      LotBoundaryValidationIssue.overlapsExistingLot => FieldStrings.overlappingLotError,
    };
  }
}
