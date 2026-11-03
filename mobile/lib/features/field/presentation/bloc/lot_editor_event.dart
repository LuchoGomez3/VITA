part of 'lot_editor_bloc.dart';

/// Eventos aceptados por el editor local de lotes.
@freezed
sealed class LotEditorEvent with _$LotEditorEvent {
  /// Agrega un nuevo vértice geográfico al final del trazo.
  const factory LotEditorEvent.vertexAdded(LocalPoint point) = _VertexAdded;

  /// Selecciona el vértice de [index].
  const factory LotEditorEvent.vertexSelected(int index) = _VertexSelected;

  /// Crea un checkpoint antes de comenzar a arrastrar un vértice.
  const factory LotEditorEvent.vertexMoveStarted(int index) = _VertexMoveStarted;

  /// Actualiza dinámicamente la posición del vértice de [index].
  const factory LotEditorEvent.vertexMoved(int index, LocalPoint point) = _VertexMoved;

  /// Elimina el vértice seleccionado.
  const factory LotEditorEvent.selectedVertexDeleted() = _SelectedVertexDeleted;

  /// Restaura la geometría anterior.
  const factory LotEditorEvent.undoRequested() = _UndoRequested;

  /// Reaplica la geometría deshecha más reciente.
  const factory LotEditorEvent.redoRequested() = _RedoRequested;

  /// Elimina todos los vértices actuales.
  const factory LotEditorEvent.clearRequested() = _ClearRequested;

  /// Valida el anillo completo y lo marca como cerrado si es válido.
  const factory LotEditorEvent.boundaryCloseRequested() = _BoundaryCloseRequested;

  /// Actualiza el nombre local del borrador.
  const factory LotEditorEvent.nameChanged(String name) = _NameChanged;

  /// Actualiza la superficie declarada en hectáreas.
  const factory LotEditorEvent.surfaceChanged(String value) = _SurfaceChanged;

  /// Continúa al formulario de datos del lote.
  const factory LotEditorEvent.detailsStepRequested() = _DetailsStepRequested;

  /// Regresa a la delimitación conservando el borrador.
  const factory LotEditorEvent.boundaryStepRequested() = _BoundaryStepRequested;

  /// Selecciona el recurso forrajero opcional.
  const factory LotEditorEvent.forageResourceChanged(String? code) = _ForageResourceChanged;

  /// Define explícitamente la disponibilidad de agua.
  const factory LotEditorEvent.waterAvailabilityChanged({required bool hasWater}) = _WaterAvailabilityChanged;

  /// Cambia el estado inicial del lote.
  const factory LotEditorEvent.statusChanged(LotStatus status) = _StatusChanged;

  /// Persiste el borrador validado exclusivamente en SQLite.
  const factory LotEditorEvent.saveRequested() = _SaveRequested;
}
