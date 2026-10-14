import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
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
import 'package:frontend_mayoral/features/field/presentation/pages/field_map_page.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
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
