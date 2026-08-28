import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary_validation.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_draft.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/save_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/validate_lot_boundary_use_case.dart';

part 'lot_editor_bloc.freezed.dart';
part 'lot_editor_event.dart';
part 'lot_editor_state.dart';

/// Coordina el borrador geométrico y el historial de edición de un lote.
class LotEditorBloc extends Bloc<LotEditorEvent, LotEditorState> {
  /// Crea el editor con un borrador vacío y validación local disponible.
  LotEditorBloc({
    required ValidateLotBoundaryUseCase validateBoundary,
    required SaveLotUseCase saveLot,
    required String establishmentId,
    List<Lot> existingLots = const [],
  }) : _validateBoundary = validateBoundary,
       _saveLot = saveLot,
       _establishmentId = establishmentId,
       super(
         LotEditorState(
           draft: LotDraft.initial(),
           validation: validateBoundary(const LotBoundary()),
           existingLots: existingLots,
         ),
       ) {
    on<_VertexAdded>(_onVertexAdded);
    on<_VertexSelected>(_onVertexSelected);
    on<_VertexMoveStarted>(_onVertexMoveStarted);
    on<_VertexMoved>(_onVertexMoved);
    on<_SelectedVertexDeleted>(_onSelectedVertexDeleted);
    on<_UndoRequested>(_onUndoRequested);
    on<_RedoRequested>(_onRedoRequested);
    on<_ClearRequested>(_onClearRequested);
    on<_BoundaryCloseRequested>(_onBoundaryCloseRequested);
    on<_NameChanged>(_onNameChanged);
    on<_SaveRequested>(_onSaveRequested);
  }

  final ValidateLotBoundaryUseCase _validateBoundary;
  final SaveLotUseCase _saveLot;
  final String _establishmentId;

  void _onVertexAdded(_VertexAdded event, Emitter<LotEditorState> emit) {
    if (state.isClosed) {
      return;
    }
    final vertices = [...state.vertices, event.point];
    emit(
      _stateWithVertices(
        vertices,
        selectedVertexIndex: vertices.length - 1,
        undoStack: [...state.undoStack, state.vertices],
        redoStack: const [],
      ),
    );
  }

  void _onVertexSelected(
    _VertexSelected event,
    Emitter<LotEditorState> emit,
  ) {
    emit(state.copyWith(selectedVertexIndex: event.index));
  }

  void _onVertexMoveStarted(
    _VertexMoveStarted event,
    Emitter<LotEditorState> emit,
  ) {
    emit(
      state.copyWith(
        selectedVertexIndex: event.index,
        undoStack: [...state.undoStack, state.vertices],
        redoStack: const [],
      ),
    );
  }

  void _onVertexMoved(_VertexMoved event, Emitter<LotEditorState> emit) {
    if (event.index < 0 || event.index >= state.vertices.length) {
      return;
    }
    final vertices = [...state.vertices]..[event.index] = event.point;
    final updated = _stateWithVertices(
      vertices,
      selectedVertexIndex: event.index,
      undoStack: state.undoStack,
      redoStack: state.redoStack,
      preserveClosed: true,
    );
    emit(updated);
  }

  void _onSelectedVertexDeleted(
    _SelectedVertexDeleted event,
    Emitter<LotEditorState> emit,
  ) {
    final selectedIndex = state.selectedVertexIndex;
    if (selectedIndex == null) {
      return;
    }
    final vertices = [...state.vertices]..removeAt(selectedIndex);
    emit(
      _stateWithVertices(
        vertices,
        undoStack: [...state.undoStack, state.vertices],
        redoStack: const [],
        preserveClosed: true,
      ),
    );
  }

  void _onUndoRequested(_UndoRequested event, Emitter<LotEditorState> emit) {
    if (state.undoStack.isEmpty) {
      return;
    }
    final previousVertices = state.undoStack.last;
    emit(
      _stateWithVertices(
        previousVertices,
        undoStack: state.undoStack.sublist(0, state.undoStack.length - 1),
        redoStack: [...state.redoStack, state.vertices],
        preserveClosed: true,
      ),
    );
  }

  void _onRedoRequested(_RedoRequested event, Emitter<LotEditorState> emit) {
    if (state.redoStack.isEmpty) {
      return;
    }
    final nextVertices = state.redoStack.last;
    emit(
      _stateWithVertices(
        nextVertices,
        undoStack: [...state.undoStack, state.vertices],
        redoStack: state.redoStack.sublist(0, state.redoStack.length - 1),
        preserveClosed: true,
      ),
    );
  }

  void _onClearRequested(_ClearRequested event, Emitter<LotEditorState> emit) {
    if (state.vertices.isEmpty) {
      return;
    }
    emit(
      _stateWithVertices(
        const [],
        undoStack: [...state.undoStack, state.vertices],
        redoStack: const [],
      ),
    );
  }

  void _onBoundaryCloseRequested(
    _BoundaryCloseRequested event,
    Emitter<LotEditorState> emit,
  ) {
    final validation = _validateBoundary(state.draft.boundary);
    emit(
      state.copyWith(
        validation: validation,
        isClosed: validation.isValid,
        showValidationErrors: true,
        selectedVertexIndex: null,
      ),
    );
  }

  void _onNameChanged(_NameChanged event, Emitter<LotEditorState> emit) {
    emit(state.copyWith(draft: state.draft.copyWith(name: event.name), errorMessage: null));
  }

  Future<void> _onSaveRequested(
    _SaveRequested event,
    Emitter<LotEditorState> emit,
  ) async {
    if (!state.canComplete || state.isSaving) return;
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await _saveLot(
      establishmentId: _establishmentId,
      draft: state.draft,
    );
    switch (result) {
      case Success<Lot>(:final data):
        emit(state.copyWith(isSaving: false, savedLot: data));
      case Failure<Lot>(:final error):
        emit(state.copyWith(isSaving: false, errorMessage: error.message));
    }
  }

  LotEditorState _stateWithVertices(
    List<LocalPoint> vertices, {
    required List<List<LocalPoint>> undoStack,
    required List<List<LocalPoint>> redoStack,
    int? selectedVertexIndex,
    bool preserveClosed = false,
  }) {
    final boundary = LotBoundary(vertices: vertices);
    final validation = _validateBoundary(boundary);
    return state.copyWith(
      draft: state.draft.copyWith(boundary: boundary),
      validation: validation,
      selectedVertexIndex: selectedVertexIndex,
      undoStack: undoStack,
      redoStack: redoStack,
      isClosed: preserveClosed && state.isClosed && validation.isValid,
    );
  }
}
