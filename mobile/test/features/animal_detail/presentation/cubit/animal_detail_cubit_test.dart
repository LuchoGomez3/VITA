import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_location.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_location_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_photo_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_photo_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/watch_animal_location_use_case.dart';
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
      watchAnimalLocationUseCase: const WatchAnimalLocationUseCase(_LocationRepository()),
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
      watchAnimalLocationUseCase: const WatchAnimalLocationUseCase(_LocationRepository()),
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

  test('reconciliar ubicación conserva foto y pesajes y cierra la escucha al salir', () async {
    final changes = StreamController<Result<AnimalLocation?>>.broadcast();
    addTearDown(changes.close);
    final detailRepository = _FakeAnimalDetailRepository();
    final photoRepository = _FakeAnimalPhotoRepository(Result.success(AnimalPhoto.fromBytes([1, 2, 3])));
    final cubit = AnimalDetailCubit(
      watchAnimalLocationUseCase: WatchAnimalLocationUseCase(_LocationRepository(changes.stream)),
      getAnimalDetailUseCase: GetAnimalDetailUseCase(detailRepository),
      getAnimalPhotoUseCase: GetAnimalPhotoUseCase(photoRepository),
      retryAnimalSyncUseCase: RetryAnimalSyncUseCase(detailRepository),
    );
    await cubit.loadAnimalData(_animal.id);
    final photo = cubit.state.photo;
    changes.add(Result.success(_location));
    await Future<void>.delayed(Duration.zero);

    final detail = (cubit.state.detail as Data<AnimalDetail>).data;
    expect(detail.lotId, _location.lotId);
    expect(detail.lotName, _location.lotName);
    expect(detail.weightHistory, _animal.weightHistory);
    expect(detail.currentWeight, _animal.currentWeight);
    expect(cubit.state.photo, same(photo));
    expect(photoRepository.calls, 1);
    expect(changes.hasListener, isTrue);
    await cubit.close();
    expect(changes.hasListener, isFalse);
    changes.add(Result.success(_location.copyWith(lotId: 'late')));
    await Future<void>.delayed(Duration.zero);
  });

  test('no aplica ubicaciones de otro animal o establecimiento', () async {
    final changes = StreamController<Result<AnimalLocation?>>.broadcast();
    addTearDown(changes.close);
    final detailRepository = _FakeAnimalDetailRepository();
    final cubit = AnimalDetailCubit(
      watchAnimalLocationUseCase: WatchAnimalLocationUseCase(_LocationRepository(changes.stream)),
      getAnimalDetailUseCase: GetAnimalDetailUseCase(detailRepository),
      getAnimalPhotoUseCase: GetAnimalPhotoUseCase(_FakeAnimalPhotoRepository(const Result.success(null))),
      retryAnimalSyncUseCase: RetryAnimalSyncUseCase(detailRepository),
    );
    addTearDown(cubit.close);
    await cubit.loadAnimalData(_animal.id);
    changes
      ..add(Result.success(_location.copyWith(animalId: 'other')))
      ..add(Result.success(_location.copyWith(establishmentId: 'other')));
    await Future<void>.delayed(Duration.zero);
    expect((cubit.state.detail as Data<AnimalDetail>).data, _animal);
  });

  test('una foto anterior no reemplaza la foto de otra ficha', () async {
    final details = _FakeAnimalDetailRepository();
    final photos = _SwitchingPhotoRepository();
    final cubit = AnimalDetailCubit(
      watchAnimalLocationUseCase: const WatchAnimalLocationUseCase(_LocationRepository()),
      getAnimalDetailUseCase: GetAnimalDetailUseCase(details),
      getAnimalPhotoUseCase: GetAnimalPhotoUseCase(photos),
      retryAnimalSyncUseCase: RetryAnimalSyncUseCase(details),
    );
    addTearDown(cubit.close);
    final oldLoad = cubit.loadAnimalData(_animal.id);
    await photos.requested.future;
    await cubit.loadAnimalData('other');
    photos.pending.complete(Result.success(AnimalPhoto.fromBytes([1, 2, 3])));
    await oldLoad;
    expect((cubit.state.detail as Data<AnimalDetail>).data.id, 'other');
    expect((cubit.state.photo as Data<AnimalPhoto?>).data, isNull);
  });

  test('una respuesta de detalle anterior no reinicia la escucha de otra ficha', () async {
    final details = _DelayedDetailRepository();
    final cubit = AnimalDetailCubit(
      watchAnimalLocationUseCase: const WatchAnimalLocationUseCase(_LocationRepository()),
      getAnimalDetailUseCase: GetAnimalDetailUseCase(details),
      getAnimalPhotoUseCase: GetAnimalPhotoUseCase(_FakeAnimalPhotoRepository(const Result.success(null))),
      retryAnimalSyncUseCase: RetryAnimalSyncUseCase(details),
    );
    addTearDown(cubit.close);
    final oldLoad = cubit.loadAnimalData(_animal.id);
    final latestLoad = cubit.loadAnimalData('other');
    details.latest.complete(Result.success(_animal.copyWith(id: 'other')));
    await latestLoad;
    details.old.complete(Result.success(_animal));
    await oldLoad;
    expect((cubit.state.detail as Data<AnimalDetail>).data.id, 'other');
  });
}

final _location = AnimalLocation(
  animalId: _animal.id,
  establishmentId: _animal.establishmentId,
  lotId: 'authoritative-lot',
  lotName: 'Potrero reconciliado',
  updatedAt: DateTime.utc(2026, 11),
);

class _LocationRepository implements AnimalLocationRepository {
  const _LocationRepository([this.changes = const Stream.empty()]);
  final Stream<Result<AnimalLocation?>> changes;

  @override
  Stream<Result<AnimalLocation?>> watchLocation(String animalId, {required String establishmentId}) => changes;
}

class _FakeAnimalDetailRepository implements AnimalDetailRepository {
  @override
  Future<Result<AnimalDetail>> getById(String animalId) async {
    return Result.success(_animal.copyWith(id: animalId));
  }

  @override
  Future<Result<void>> retrySync(String animalId) async {
    return const Result.success(null);
  }
}

class _DelayedDetailRepository extends Fake implements AnimalDetailRepository {
  final old = Completer<Result<AnimalDetail>>();
  final latest = Completer<Result<AnimalDetail>>();

  @override
  Future<Result<AnimalDetail>> getById(String animalId) => animalId == _animal.id ? old.future : latest.future;
}

class _SwitchingPhotoRepository implements AnimalPhotoRepository {
  final requested = Completer<void>();
  final pending = Completer<Result<AnimalPhoto?>>();

  @override
  Future<Result<AnimalPhoto?>> getPhoto({required String establishmentId, required String animalId}) {
    if (animalId != _animal.id) return Future.value(const Result.success(null));
    requested.complete();
    return pending.future;
  }
}

class _FakeAnimalPhotoRepository implements AnimalPhotoRepository {
  _FakeAnimalPhotoRepository(this.result);

  final Result<AnimalPhoto?> result;
  String? establishmentId;
  String? animalId;
  int calls = 0;

  @override
  Future<Result<AnimalPhoto?>> getPhoto({
    required String establishmentId,
    required String animalId,
  }) async {
    calls++;
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
