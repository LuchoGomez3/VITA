import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_photo_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_photo_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/pages/animal_detail_page.dart';

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
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      },
    );
  }
}

AnimalDetailCubit _createCubit() {
  const detailRepository = _DetailRepository();
  const photoRepository = _PhotoRepository();
  return AnimalDetailCubit(
    getAnimalDetailUseCase: const GetAnimalDetailUseCase(detailRepository),
    getAnimalPhotoUseCase: const GetAnimalPhotoUseCase(photoRepository),
    retryAnimalSyncUseCase: const RetryAnimalSyncUseCase(detailRepository),
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

class _PhotoRepository implements AnimalPhotoRepository {
  const _PhotoRepository();

  @override
  Future<Result<AnimalPhoto?>> getPhoto({
    required String establishmentId,
    required String animalId,
  }) async {
    return Result.success(
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
