import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_genealogy_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_photo_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_genealogy_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_photo_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_genealogy_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/pages/animal_detail_page.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_general_tab.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/movement_history_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/strings/animal_movement_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets(
      'supports ${size.width}x${size.height} with 200% text and a photo',
      (tester) async {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
              ),
              child: child!,
            ),
            home: AnimalDetailPage(
              animalId: _animal.id,
              createCubit: _createCubit,
              createGenealogyCubit: _createGenealogyCubit,
              createMovementHistoryCubit: _createMovementHistoryCubit,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(TabBar), findsOneWidget);
        expect(find.byType(AnimalGeneralTab), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      },
    );
  }

  testWidgets('keeps tabs usable while the optional photo is loading', (tester) async {
    final photoResult = Completer<Result<AnimalPhoto?>>();
    await tester.pumpWidget(
      MaterialApp(
        home: AnimalDetailPage(
          animalId: _animal.id,
          createCubit: () => _createCubit(photoResult: photoResult.future),
          createGenealogyCubit: _createGenealogyCubit,
          createMovementHistoryCubit: _createMovementHistoryCubit,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_animal.breed), findsWidgets);
    expect(find.text(AnimalDetailStrings.photoPlaceholder), findsOneWidget);

    await tester.tap(find.text(AnimalDetailStrings.weighingsTab));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);

    photoResult.complete(Result.success(AnimalPhoto.fromBytes(base64Decode(_onePixelPng))));
    await tester.pumpAndSettle();
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, AnimalFichaTab.weighings.index);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.text(AnimalDetailStrings.generalTab));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  for (final (name, result) in <(String, Result<AnimalPhoto?>)>[
    ('absent', const Result.success(null)),
    ('failed', const Result.failure(DomainException(message: 'Optional photo failed'))),
    ('invalid', Result.success(AnimalPhoto.fromBytes([1, 2, 3]))),
  ]) {
    testWidgets('keeps the new placeholder and animal data when photo is $name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimalDetailPage(
            animalId: _animal.id,
            createCubit: () => _createCubit(photoResult: Future.value(result)),
            createGenealogyCubit: _createGenealogyCubit,
            createMovementHistoryCubit: _createMovementHistoryCubit,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnimalGeneralTab), findsOneWidget);
      expect(find.text(_animal.breed), findsWidgets);
      expect(find.text(AnimalDetailStrings.photoPlaceholder), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });
  }
  testWidgets('genealogía y movimientos conviven y actualizan el destino al volver de mover', (tester) async {
    final detailRepository = _MovingDetailRepository();
    final movementRepository = _MovementRepository();
    final router = GoRouter(
      initialLocation: AppRoutes.animalDetailById(_animal.id),
      routes: [
        GoRoute(
          path: AppRoutes.animalDetail,
          builder: (context, state) => AnimalDetailPage(
            animalId: state.pathParameters['animalId']!,
            createCubit: () => _createCubit(detailRepository: detailRepository),
            createGenealogyCubit: _createGenealogyCubit,
            createMovementHistoryCubit: () => MovementHistoryCubit(
              GetAnimalMovementHistoryUseCase(movementRepository),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.animalGroupMovement,
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () {
                detailRepository.animal = _animal.copyWith(lotId: 'destino-id', lotName: 'Potrero destino');
                movementRepository.history = [
                  MovementHistoryEntry(
                    movementId: 'movimiento-id',
                    fromLotName: _animal.lotName,
                    toLotName: 'Potrero destino',
                    occurredAt: DateTime.utc(2026, 10, 29),
                    reason: 'Rotación de pastoreo',
                    isPending: true,
                  ),
                ];
                context.pop(const GroupMovementSummary(movedCount: 1, alreadyThereCount: 0));
              },
              child: const Text('Confirmar movimiento'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AnimalDetailStrings.genealogyTab));
    await tester.pumpAndSettle();
    expect(find.text(AnimalDetailStrings.genealogyEmpty), findsOneWidget);

    await tester.tap(find.text(AnimalDetailStrings.movementsTab));
    await tester.pumpAndSettle();
    expect(find.text(AnimalMovementStrings.historyEmpty), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar movimiento'));
    await tester.pumpAndSettle();

    expect(movementRepository.loadedAnimalIds, [_animal.id, _animal.id]);
    expect(find.text('Rotación de pastoreo'), findsOneWidget);
    expect(find.text(AnimalMovementStrings.pendingSync), findsOneWidget);
    expect(
      find.text('${AnimalMovementStrings.moved(1, 'Potrero destino')} ${AnimalMovementStrings.savedOffline}'),
      findsOneWidget,
    );

    await tester.tap(find.text(AnimalDetailStrings.generalTab));
    await tester.pumpAndSettle();
    expect(find.text('Potrero destino'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}

AnimalGenealogyCubit _createGenealogyCubit() => AnimalGenealogyCubit(
  const GetAnimalGenealogyUseCase(_EmptyFamilyRepository()),
);

class _EmptyFamilyRepository implements AnimalGenealogyRepository {
  const _EmptyFamilyRepository();

  @override
  Future<Result<List<GenealogyAnimalRecord>>> getLocalFamily(String animalId) async => const Result.success([]);
}

MovementHistoryCubit _createMovementHistoryCubit() => MovementHistoryCubit(
  GetAnimalMovementHistoryUseCase(_MovementRepository()),
);

AnimalDetailCubit _createCubit({
  Future<Result<AnimalPhoto?>>? photoResult,
  AnimalDetailRepository detailRepository = const _DetailRepository(),
}) {
  final photoRepository = _PhotoRepository(result: photoResult);
  return AnimalDetailCubit(
    getAnimalDetailUseCase: GetAnimalDetailUseCase(detailRepository),
    getAnimalPhotoUseCase: GetAnimalPhotoUseCase(photoRepository),
    retryAnimalSyncUseCase: RetryAnimalSyncUseCase(detailRepository),
  );
}

class _DetailRepository implements AnimalDetailRepository {
  const _DetailRepository();

  @override
  Future<Result<AnimalDetail>> getById(String animalId) async {
    return Result.success(_animal);
  }

  @override
  Future<Result<void>> retrySync(String animalId) async {
    return const Result.success(null);
  }
}

class _MovingDetailRepository implements AnimalDetailRepository {
  AnimalDetail animal = _animal;

  @override
  Future<Result<AnimalDetail>> getById(String animalId) async => Result.success(animal);

  @override
  Future<Result<void>> retrySync(String animalId) async => const Result.success(null);
}

class _MovementRepository implements AnimalMovementRepository {
  List<MovementHistoryEntry> history = [];
  final loadedAnimalIds = <String>[];

  @override
  Future<Result<List<MovementHistoryEntry>>> getHistory(String animalId) async {
    loadedAnimalIds.add(animalId);
    return Result.success(history);
  }

  @override
  Future<Result<MovementAnimal?>> getAnimal(String animalId) => throw UnimplementedError();

  @override
  Future<Result<MovementAnimal?>> findAnimalByTag(String tag) => throw UnimplementedError();

  @override
  Future<Result<List<MovementDestination>>> getDestinations(String establishmentId) => throw UnimplementedError();
}

class _PhotoRepository implements AnimalPhotoRepository {
  const _PhotoRepository({this.result});

  final Future<Result<AnimalPhoto?>>? result;

  @override
  Future<Result<AnimalPhoto?>> getPhoto({
    required String establishmentId,
    required String animalId,
  }) async {
    return result ??
        Result.success(
          AnimalPhoto.fromBytes(base64Decode(_onePixelPng)),
        );
  }
}

final _animal = AnimalDetail(
  id: 'animal-id',
  rfidTagNumber: '982000412991416',
  visualTag: '003 1295',
  sex: AnimalSex.female,
  breed: 'Aberdeen Angus',
  birthDate: DateTime.utc(2025),
  categoryId: 'category-id',
  categoryName: 'Vaquillona de reposición',
  lotId: 'lot-id',
  lotName: 'Lote norte con nombre extenso',
  establishmentId: 'establishment-id',
  currentWeight: 300,
  weighingMethod: AnimalWeighingMethod.artificialIntelligence,
  weighingDate: DateTime.utc(2026, 10),
  syncStatus: AnimalSyncStatus.synchronized,
  productiveStatus: AnimalProductiveStatus.active,
  updatedAt: DateTime.utc(2026, 10),
  observations: 'Observación extensa para verificar el ajuste del contenido.',
  weightHistory: const [],
);

const _onePixelPng = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScL0WQAAAABJRU5ErkJggg==';
