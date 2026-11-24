import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/field_establishment_repository.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_animal_repository.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_field_establishments_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_animal_counts_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lots_use_case.dart';
import 'package:frontend_mayoral/features/field/presentation/cubit/lot_overview_cubit.dart';
import 'package:frontend_mayoral/features/field/presentation/geometry/local_canvas_projection.dart';
import 'package:frontend_mayoral/features/field/presentation/pages/field_map_page.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_map_background.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_overview_canvas.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('el fondo satelital dibuja el límite guardado en rojo y lo cierra', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FieldMapBackground(
            location: (
              center: (latitude: -33.1, longitude: -64.3),
              boundary: [
                (latitude: -33.10, longitude: -64.36),
                (latitude: -33.11, longitude: -64.35),
                (latitude: -33.12, longitude: -64.34),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final layer = tester.widget<PolylineLayer<Object>>(find.byType(PolylineLayer<Object>));
    final boundary = layer.polylines.single;
    expect(boundary.color, AppColors.error);
    expect(boundary.pattern.segments, isNotEmpty);
    expect(boundary.points, hasLength(4));
    expect(boundary.points.last, boundary.points.first);
  });

  testWidgets('el zoom mueve el fondo y los lotes juntos y el arrastre deja el mapa fijo', (tester) async {
    String? selectedLotId;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LotOverviewCanvas(
            lots: [_lot()],
            onLotSelected: (id) => selectedLotId = id,
            photo: base64Decode(
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final photo = find.byType(Image);
    final lots = find.byType(PolygonLayer<String>);
    final initialPhoto = tester.getRect(photo);
    final initialLots = tester.getRect(lots);
    await tester.dragFrom(initialLots.center, const Offset(70, 60));
    await tester.pumpAndSettle();
    expect(tester.getRect(photo), initialPhoto);
    expect(tester.getRect(lots), initialLots);

    await tester.tap(find.byTooltip(FieldStrings.zoomInMap));
    await tester.pumpAndSettle();
    expect(tester.getRect(photo).width, closeTo(initialPhoto.width * 1.5, 0.1));
    expect(tester.getRect(lots).width, closeTo(initialLots.width * 1.5, 0.1));
    expect(tester.getRect(photo).center, initialPhoto.center);
    expect(tester.getRect(lots).center, initialLots.center);

    final camera = MapCamera.of(tester.element(lots));
    final point = camera.latLngToScreenOffset(LocalCanvasProjection.toViewport(const LocalPoint(x: 260, y: 200)));
    await tester.tapAt(tester.renderObject<RenderBox>(lots).localToGlobal(point));
    await tester.pumpAndSettle();
    expect(selectedLotId, 'lot-1');

    await tester.tap(find.byTooltip(FieldStrings.zoomOutMap));
    await tester.pumpAndSettle();
    expect(tester.getRect(photo), initialPhoto);
    expect(tester.getRect(lots), initialLots);
  });

  testWidgets('recarga SQLite al volver de eliminar un lote', (tester) async {
    final lots = _MutableLotRepository([_lot()]);
    final router = GoRouter(
      initialLocation: '/campo',
      routes: [
        GoRoute(
          path: '/campo',
          builder: (_, _) => FieldMapPage(
            createCubit: () => LotOverviewCubit(
              getEstablishments: const GetFieldEstablishmentsUseCase(
                _EstablishmentRepository(),
              ),
              getLots: GetLotsUseCase(lots),
              getAnimalCounts: const GetLotAnimalCountsUseCase(
                _AnimalRepository(),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/campo/:lotId',
          builder: (context, _) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  lots.records.clear();
                  context.pop(true);
                },
                child: const Text('Confirmar eliminación de prueba'),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final canvas = find.byType(LotOverviewCanvas);
    final normalHeight = tester.getSize(canvas).height;
    await tester.tap(find.byTooltip(FieldStrings.zoomInMap));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(FieldStrings.expandMap));
    await tester.pumpAndSettle();
    expect(tester.getSize(canvas).height, greaterThan(normalHeight));
    expect(find.byTooltip(FieldStrings.zoomOutMap), findsOneWidget);
    expect(find.text(FieldStrings.listTab), findsNothing);
    await tester.tap(find.byTooltip(FieldStrings.collapseMap));
    await tester.pumpAndSettle();
    expect(tester.getSize(canvas).height, normalHeight);

    await tester.tap(find.text(FieldStrings.listTab));
    await tester.pump();
    expect(find.text('Lote a eliminar'), findsOneWidget);

    await tester.tap(find.text('Lote a eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar eliminación de prueba'));
    await tester.pumpAndSettle();

    expect(find.text('Lote a eliminar'), findsNothing);
    expect(find.text(FieldStrings.noLocalLotsMessage), findsOneWidget);
    expect(lots.readCount, 2);
  });
}

Lot _lot() => Lot(
  id: 'lot-1',
  establishmentId: 'est-1',
  name: 'Lote a eliminar',
  boundary: const LotBoundary(
    vertices: [
      LocalPoint(x: 100, y: 100),
      LocalPoint(x: 300, y: 100),
      LocalPoint(x: 300, y: 300),
    ],
  ),
  surfaceTenths: 100,
  hasWater: true,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class _EstablishmentRepository implements FieldEstablishmentRepository {
  const _EstablishmentRepository();

  @override
  Future<Result<Map<String, String>>> getEstablishments() async => const Result.success({'est-1': 'Establecimiento'});
}

class _AnimalRepository implements LotAnimalRepository {
  const _AnimalRepository();

  @override
  Future<Result<List<LotAnimalSummary>>> getAnimals({
    required String establishmentId,
    String? lotId,
  }) async => const Result.success([]);
}

class _MutableLotRepository implements LotRepository {
  _MutableLotRepository(this.records);

  final List<Lot> records;
  int readCount = 0;

  @override
  Future<Result<Lot>> getLot(String lotId) async => Result.success(records.singleWhere((lot) => lot.id == lotId));

  @override
  Future<Result<List<Lot>>> getLots(String establishmentId) async {
    readCount++;
    return Result.success(List.unmodifiable(records));
  }

  @override
  Future<Result<Lot>> saveLot(Lot lot) async => Result.success(lot);
}
