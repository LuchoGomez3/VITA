import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_photo_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_photo_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';

void main() {
  test('keeps the animal detail when the optional photo fails', () async {
    final detailRepository = _FakeAnimalDetailRepository();
    final photoRepository = _FakeAnimalPhotoRepository(
      const Result.failure(
        DomainException(message: 'No se pudo leer la foto.'),
      ),
    );
    final cubit = AnimalDetailCubit(
      getAnimalDetailUseCase: GetAnimalDetailUseCase(detailRepository),
      getAnimalPhotoUseCase: GetAnimalPhotoUseCase(photoRepository),
      retryAnimalSyncUseCase: RetryAnimalSyncUseCase(detailRepository),
    );

    await cubit.loadAnimalData(_animal.id);

    expect(cubit.state.detail, isA<Data<AnimalDetail>>());
    expect(cubit.state.photo, isA<ResultError<AnimalPhoto?>>());
    expect(photoRepository.establishmentId, _animal.establishmentId);
    expect(photoRepository.animalId, _animal.id);
    await cubit.close();
  });

  test('does not emit a photo after the cubit is closed', () async {
    final detailRepository = _FakeAnimalDetailRepository();
    final photoRepository = _PendingAnimalPhotoRepository();
    final cubit = AnimalDetailCubit(
      getAnimalDetailUseCase: GetAnimalDetailUseCase(detailRepository),
      getAnimalPhotoUseCase: GetAnimalPhotoUseCase(photoRepository),
      retryAnimalSyncUseCase: RetryAnimalSyncUseCase(detailRepository),
    );

    final load = cubit.loadAnimalData(_animal.id);
    await photoRepository.requested.future;
    expect(cubit.state.detail, isA<Data<AnimalDetail>>());
    expect(cubit.state.photo, isA<Loading<AnimalPhoto?>>());

    await cubit.close();
    photoRepository.result.complete(
      Result.success(AnimalPhoto.fromBytes([1, 2, 3])),
    );

    await expectLater(load, completes);
  });
}

class _FakeAnimalDetailRepository implements AnimalDetailRepository {
  @override
  Future<Result<AnimalDetail>> getById(String animalId) async {
    return Result.success(_animal);
  }

  @override
  Future<Result<void>> retrySync(String animalId) async {
    return const Result.success(null);
  }
}

class _FakeAnimalPhotoRepository implements AnimalPhotoRepository {
  _FakeAnimalPhotoRepository(this.result);

  final Result<AnimalPhoto?> result;
  String? establishmentId;
  String? animalId;

  @override
  Future<Result<AnimalPhoto?>> getPhoto({
    required String establishmentId,
    required String animalId,
  }) async {
    this.establishmentId = establishmentId;
    this.animalId = animalId;
    return result;
  }
}

class _PendingAnimalPhotoRepository implements AnimalPhotoRepository {
  final requested = Completer<void>();
  final result = Completer<Result<AnimalPhoto?>>();

  @override
  Future<Result<AnimalPhoto?>> getPhoto({
    required String establishmentId,
    required String animalId,
  }) {
    requested.complete();
    return result.future;
  }
}

final _animal = AnimalDetail(
  id: 'animal-id',
  rfidTagNumber: '982000412991416',
  visualTag: '003 1295',
  sex: AnimalSex.female,
  breed: 'Angus',
  birthDate: DateTime.utc(2025),
  categoryId: 'category-id',
  categoryName: 'Vaca',
  lotId: 'lot-id',
  lotName: 'Lote norte',
  establishmentId: 'establishment-id',
  currentWeight: 300,
  weighingMethod: AnimalWeighingMethod.manual,
  weighingDate: DateTime.utc(2026, 10),
  syncStatus: AnimalSyncStatus.synchronized,
  productiveStatus: AnimalProductiveStatus.active,
  updatedAt: DateTime.utc(2026, 10),
  weightHistory: const [],
);
