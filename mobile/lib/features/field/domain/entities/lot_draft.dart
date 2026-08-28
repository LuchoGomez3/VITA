import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';

part 'lot_draft.freezed.dart';

/// Borrador editable que se convierte en un lote al confirmar el alta local.
@freezed
sealed class LotDraft with _$LotDraft {
  /// Crea el borrador editable de un lote.
  const factory LotDraft({
    required String name,
    required LotBoundary boundary,
  }) = _LotDraft;

  /// Crea un borrador vacío para iniciar el flujo.
  factory LotDraft.initial() => const LotDraft(
    name: '',
    boundary: LotBoundary(),
  );
}
