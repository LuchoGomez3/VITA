part of 'lot_editor_bloc.dart';

/// Paso visible del alta local.
enum LotEditorStep {
  /// Nombre, superficie y delimitación.
  boundary,

  /// Forraje, agua, estado y confirmación.
  details,
}

/// Estado inmutable de la delimitación local de un lote.
@freezed
sealed class LotEditorState with _$LotEditorState {
  /// Crea el estado completo del editor.
  const factory LotEditorState({
    required LotDraft draft,
    required LotBoundaryValidation validation,
    @Default(LotEditorStep.boundary) LotEditorStep step,
    @Default(<List<LocalPoint>>[]) List<List<LocalPoint>> undoStack,
    @Default(<List<LocalPoint>>[]) List<List<LocalPoint>> redoStack,
    @Default(false) bool isClosed,
    @Default(false) bool showValidationErrors,
    int? selectedVertexIndex,
    @Default(<Lot>[]) List<Lot> existingLots,
    @Default(ResultState<Lot>.initial()) ResultState<Lot> submitResult,
  }) = _LotEditorState;

  const LotEditorState._();

  /// Vértices actuales del borrador.
  List<LocalPoint> get vertices => draft.boundary.vertices;

  /// Indica si existe una escritura local en curso.
  bool get isSaving => submitResult is Loading<Lot>;

  /// Lote persistido cuando el alta finalizo correctamente.
  Lot? get savedLot => switch (submitResult) {
    Data<Lot>(:final data) => data,
    _ => null,
  };

  /// Mensaje de la ultima falla de guardado, si existe.
  String? get errorMessage => switch (submitResult) {
    ResultError<Lot>(:final error) => error.message,
    _ => null,
  };

  /// Indica si existe una acción geométrica para deshacer.
  bool get canUndo => undoStack.isNotEmpty;

  /// Indica si existe una acción geométrica para rehacer.
  bool get canRedo => redoStack.isNotEmpty;

  /// Indica si la Fase 1 puede devolver un borrador válido.
  bool get canContinue =>
      isClosed && validation.isValid && draft.name.trim().isNotEmpty && draft.surfaceTenths > 0 && !isSaving;

  /// Indica si el lote completo puede persistirse.
  bool get canComplete => step == LotEditorStep.details && canContinue && draft.hasWater != null;
}
