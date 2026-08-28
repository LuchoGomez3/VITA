part of 'lot_editor_bloc.dart';

/// Estado inmutable de la delimitación local de un lote.
@freezed
sealed class LotEditorState with _$LotEditorState {
  /// Crea el estado completo del editor.
  const factory LotEditorState({
    required LotDraft draft,
    required LotBoundaryValidation validation,
    @Default(<List<LocalPoint>>[]) List<List<LocalPoint>> undoStack,
    @Default(<List<LocalPoint>>[]) List<List<LocalPoint>> redoStack,
    @Default(false) bool isClosed,
    @Default(false) bool showValidationErrors,
    int? selectedVertexIndex,
    @Default(<Lot>[]) List<Lot> existingLots,
    @Default(false) bool isSaving,
    Lot? savedLot,
    String? errorMessage,
  }) = _LotEditorState;

  const LotEditorState._();

  /// Vértices actuales del borrador.
  List<LocalPoint> get vertices => draft.boundary.vertices;

  /// Indica si existe una acción geométrica para deshacer.
  bool get canUndo => undoStack.isNotEmpty;

  /// Indica si existe una acción geométrica para rehacer.
  bool get canRedo => redoStack.isNotEmpty;

  /// Indica si la Fase 1 puede devolver un borrador válido.
  bool get canComplete => isClosed && validation.isValid && draft.name.trim().isNotEmpty && !isSaving;
}
