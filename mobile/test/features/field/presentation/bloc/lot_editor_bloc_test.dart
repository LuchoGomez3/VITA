import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/data/services/turf_lot_overlap_validator.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:frontend_mayoral/features/field/domain/services/local_lot_boundary_validator.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/save_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/validate_lot_placement_use_case.dart';
import 'package:frontend_mayoral/features/field/presentation/bloc/lot_editor_bloc.dart';

void main() {
  late _MemoryLotRepository repository;
  late LotEditorBloc bloc;

  setUp(() {
    repository = _MemoryLotRepository();
    const validator = LocalLotBoundaryValidator();
    const overlapValidator = TurfLotOverlapValidator();
    bloc = LotEditorBloc(
      validatePlacement: const ValidateLotPlacementUseCase(
        boundaryValidator: validator,
        overlapValidator: overlapValidator,
      ),
      saveLot: SaveLotUseCase(
        repository: repository,
        validator: validator,
        overlapValidator: overlapValidator,
        createId: () => 'lot-1',
        now: () => DateTime.utc(2026, 8, 28),
      ),
      establishmentId: 'est-1',
    );
  });

  tearDown(() => bloc.close());

  Future<LotEditorState> dispatch(LotEditorEvent event) {
    final next = bloc.stream.first;
    bloc.add(event);
    return next;
  }

  Future<void> addValidRectangle() async {
    for (final point in const [
      LocalPoint(x: 100, y: 100),
      LocalPoint(x: 300, y: 100),
      LocalPoint(x: 300, y: 300),
      LocalPoint(x: 100, y: 300),
    ]) {
      await dispatch(LotEditorEvent.vertexAdded(point));
    }
  }

  test('agrega y mueve únicamente el vértice seleccionado', () async {
    await addValidRectangle();
    await dispatch(const LotEditorEvent.vertexMoveStarted(0));
    final state = await dispatch(
      const LotEditorEvent.vertexMoved(0, LocalPoint(x: 80, y: 90)),
    );

    expect(state.vertices.first, const LocalPoint(x: 80, y: 90));
    expect(state.vertices[1], const LocalPoint(x: 300, y: 100));
  });

  test('cierra, nombra y guarda durablemente el lote', () async {
    await addValidRectangle();
    await dispatch(const LotEditorEvent.boundaryCloseRequested());
    await dispatch(const LotEditorEvent.nameChanged('Lote norte'));
    await dispatch(const LotEditorEvent.surfaceChanged('45,7'));
    await dispatch(const LotEditorEvent.detailsStepRequested());
    await dispatch(const LotEditorEvent.waterAvailabilityChanged(hasWater: true));

    final saving = await dispatch(const LotEditorEvent.saveRequested());
    expect(saving.isSaving, isTrue);
    final saved = await bloc.stream.firstWhere((state) => state.savedLot != null);

    expect(saved.savedLot?.id, 'lot-1');
    expect(saved.savedLot?.establishmentId, 'est-1');
    expect(repository.lots, hasLength(1));
  });

  test('deshacer restaura el vértice anterior después de mover', () async {
    await addValidRectangle();
    await dispatch(const LotEditorEvent.vertexMoveStarted(0));
    await dispatch(const LotEditorEvent.vertexMoved(0, LocalPoint(x: 50, y: 50)));
    final state = await dispatch(const LotEditorEvent.undoRequested());

    expect(state.vertices.first, const LocalPoint(x: 100, y: 100));
    expect(state.canRedo, isTrue);
  });
}

class _MemoryLotRepository implements LotRepository {
  final List<Lot> lots = [];

  @override
  Future<Result<List<Lot>>> getLots(String establishmentId) async =>
      Result.success(lots.where((lot) => lot.establishmentId == establishmentId).toList());

  @override
  Future<Result<Lot>> saveLot(Lot lot) async {
    lots.add(lot);
    return Result.success(lot);
  }

  @override
  Future<Result<Lot>> getLot(String lotId) async => Result.success(lots.singleWhere((lot) => lot.id == lotId));
}
