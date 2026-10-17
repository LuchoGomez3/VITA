import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/data/services/turf_lot_overlap_validator.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:frontend_mayoral/features/field/domain/services/local_lot_boundary_validator.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/save_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/validate_lot_placement_use_case.dart';
import 'package:frontend_mayoral/features/field/presentation/bloc/lot_editor_bloc.dart';
import 'package:frontend_mayoral/features/field/presentation/pages/lot_editor_page.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/geographic_lot_editor.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_vertex_marker.dart';
import 'package:latlong2/latlong.dart';

void main() {
  testWidgets('renderiza el editor geográfico sin solicitar tiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LotEditorPage(createBloc: createTestLotEditorBloc),
      ),
    );
    await tester.pump();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(TileLayer), findsNothing);
    expect(find.text(FieldStrings.localDraftBadge), findsOneWidget);
    expect(find.text('Vértices'), findsNothing);
    expect(find.text('Superficie relativa'), findsNothing);
  });

  testWidgets('el callback del fondo agrega un vértice móvil', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LotEditorPage(createBloc: createTestLotEditorBloc),
      ),
    );
    await tester.pump();

    _addVertexThroughEditor(tester);
    await tester.pumpAndSettle();

    final editor = tester.widget<GeographicLotEditor>(
      find.byType(GeographicLotEditor),
    );
    expect(editor.state.vertices, hasLength(1));
    final markerLayerContext = tester.element(find.byType(MarkerLayer));
    final camera = MapCamera.of(markerLayerContext);
    expect(
      camera.visibleBounds.contains(const LatLng(20, 25)),
      isTrue,
      reason: camera.visibleBounds.toString(),
    );
    expect(find.byType(LotVertexMarker), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LotVertexMarker),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('arrastrar un pin bloquea el desplazamiento de la cámara', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LotEditorPage(createBloc: createTestLotEditorBloc),
      ),
    );
    await tester.pump();

    _addVertexThroughEditor(tester);
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(LotVertexMarker)),
    );
    await tester.pump();

    var map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(map.options.interactionOptions.flags, InteractiveFlag.none);

    await gesture.moveBy(const Offset(30, 20));
    await tester.pump();
    map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(map.options.interactionOptions.flags, InteractiveFlag.none);

    await gesture.up();
    await tester.pump();
    map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(map.options.interactionOptions.flags, InteractiveFlag.all);
  });

  testWidgets('el formulario con error no desborda al abrir el teclado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(470, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      const MaterialApp(
        home: LotEditorPage(createBloc: createOverlappingLotEditorBloc),
      ),
    );
    await tester.pump();

    final editor = tester.widget<GeographicLotEditor>(
      find.byType(GeographicLotEditor),
    );
    for (final point in const [
      LocalPoint(x: 150, y: 150),
      LocalPoint(x: 350, y: 150),
      LocalPoint(x: 350, y: 350),
      LocalPoint(x: 150, y: 350),
    ]) {
      editor.onVertexAdded(point);
    }
    await tester.pump();
    await tester.ensureVisible(find.text(FieldStrings.closeLotBoundaryCta));
    await tester.pump();
    await tester.tap(find.text(FieldStrings.closeLotBoundaryCta));
    await tester.pump();
    expect(find.text(FieldStrings.overlappingLotError), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.showKeyboard(find.byType(TextFormField).first);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

void _addVertexThroughEditor(WidgetTester tester) {
  tester.widget<GeographicLotEditor>(find.byType(GeographicLotEditor)).onVertexAdded(const LocalPoint(x: 250, y: 250));
}

LotEditorBloc createTestLotEditorBloc() {
  const validator = LocalLotBoundaryValidator();
  const overlapValidator = TurfLotOverlapValidator();
  return LotEditorBloc(
    validatePlacement: const ValidateLotPlacementUseCase(
      boundaryValidator: validator,
      overlapValidator: overlapValidator,
    ),
    saveLot: SaveLotUseCase(
      repository: _MemoryLotRepository(),
      validator: validator,
      overlapValidator: overlapValidator,
      createId: () => 'lot-test',
    ),
    establishmentId: 'establishment-test',
  );
}

LotEditorBloc createOverlappingLotEditorBloc() {
  const validator = LocalLotBoundaryValidator();
  const overlapValidator = TurfLotOverlapValidator();
  return LotEditorBloc(
    validatePlacement: const ValidateLotPlacementUseCase(
      boundaryValidator: validator,
      overlapValidator: overlapValidator,
    ),
    saveLot: SaveLotUseCase(
      repository: _MemoryLotRepository(),
      validator: validator,
      overlapValidator: overlapValidator,
      createId: () => 'lot-test',
    ),
    establishmentId: 'establishment-test',
    existingLots: [
      Lot(
        id: 'existing-lot',
        establishmentId: 'establishment-test',
        name: 'Existente',
        boundary: const LotBoundary(
          vertices: [
            LocalPoint(x: 100, y: 100),
            LocalPoint(x: 300, y: 100),
            LocalPoint(x: 300, y: 300),
            LocalPoint(x: 100, y: 300),
          ],
        ),
        surfaceTenths: 100,
        hasWater: true,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    ],
  );
}

class _MemoryLotRepository implements LotRepository {
  final List<Lot> _lots = [];

  @override
  Future<Result<Lot>> getLot(String lotId) async => Result.success(_lots.singleWhere((lot) => lot.id == lotId));

  @override
  Future<Result<List<Lot>>> getLots(String establishmentId) async => Result.success(
    _lots.where((lot) => lot.establishmentId == establishmentId).toList(),
  );

  @override
  Future<Result<Lot>> saveLot(Lot lot) async {
    _lots.add(lot);
    return Result.success(lot);
  }
}
