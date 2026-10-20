part of 'register_establishment_bloc.dart';

/// Eventos aceptados por [RegisterEstablishmentBloc].
@freezed
sealed class RegisterEstablishmentEvent with _$RegisterEstablishmentEvent {
  /// Reemplaza el borrador de registro actual.
  const factory RegisterEstablishmentEvent.draftChanged(
    RegisterEstablishmentDraft draft,
  ) = _DraftChanged;

  /// Pide la ubicación actual al GPS para el paso 3.
  const factory RegisterEstablishmentEvent.currentLocationRequested() = _CurrentLocationRequested;

  /// Agrega un vértice al final del polígono del paso 4.
  const factory RegisterEstablishmentEvent.boundaryPointAdded(BoundaryPoint point) = _BoundaryPointAdded;

  /// Marca el comienzo del arrastre de un vértice, para poder deshacerlo
  /// entero aunque el arrastre emita muchos movimientos.
  const factory RegisterEstablishmentEvent.boundaryPointMoveStarted() = _BoundaryPointMoveStarted;

  /// Mueve el vértice del índice dado durante un arrastre.
  const factory RegisterEstablishmentEvent.boundaryPointMoved(int index, BoundaryPoint point) = _BoundaryPointMoved;

  /// Agrega un vértice en la posición actual del GPS (recorriendo el campo).
  const factory RegisterEstablishmentEvent.boundaryPointFromGpsRequested() = _BoundaryPointFromGpsRequested;

  /// Deshace la última edición del polígono.
  const factory RegisterEstablishmentEvent.boundaryUndoRequested() = _BoundaryUndoRequested;

  /// Borra todos los vértices del polígono (se puede deshacer).
  const factory RegisterEstablishmentEvent.boundaryCleared() = _BoundaryCleared;

  /// Avanza al siguiente paso del registro.
  const factory RegisterEstablishmentEvent.nextStepRequested() = _NextStepRequested;

  /// Vuelve al paso anterior del registro.
  const factory RegisterEstablishmentEvent.previousStepRequested() = _PreviousStepRequested;

  /// Abre un paso especifico, por ejemplo desde la pantalla de revision.
  const factory RegisterEstablishmentEvent.stepRequested(RegisterEstablishmentStep step) = _StepRequested;

  /// Envia el borrador actual para crear el establecimiento.
  const factory RegisterEstablishmentEvent.submitRequested() = _SubmitRequested;
}
