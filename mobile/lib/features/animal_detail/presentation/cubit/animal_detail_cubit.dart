import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_location.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_photo_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/retry_animal_sync_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/watch_animal_location_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_state.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Coordina el estado de carga de la pantalla de detalle de animal.
class AnimalDetailCubit extends Cubit<AnimalDetailState> {
  /// Crea el cubit con el caso de uso que obtiene la ficha del animal.
  AnimalDetailCubit({
    required GetAnimalDetailUseCase getAnimalDetailUseCase,
    required GetAnimalPhotoUseCase getAnimalPhotoUseCase,
    required RetryAnimalSyncUseCase retryAnimalSyncUseCase,
    required WatchAnimalLocationUseCase watchAnimalLocationUseCase,
  }) : _getAnimalDetailUseCase = getAnimalDetailUseCase,
       _getAnimalPhotoUseCase = getAnimalPhotoUseCase,
       _retryAnimalSyncUseCase = retryAnimalSyncUseCase,
       _watchAnimalLocationUseCase = watchAnimalLocationUseCase,
       super(AnimalDetailState.initial);

  final GetAnimalDetailUseCase _getAnimalDetailUseCase;
  final GetAnimalPhotoUseCase _getAnimalPhotoUseCase;
  final RetryAnimalSyncUseCase _retryAnimalSyncUseCase;
  final WatchAnimalLocationUseCase _watchAnimalLocationUseCase;
  StreamSubscription<Result<AnimalLocation?>>? _locationSubscription;
  int _loadRevision = 0;

  /// Carga los datos del animal identificado por [animalId].
  Future<void> loadAnimalData(String animalId) async {
    if (isClosed) return;
    final revision = ++_loadRevision;
    unawaited(_locationSubscription?.cancel());
    emit(
      state.copyWith(
        detail: const ResultState.loading(),
        photo: const ResultState.initial(),
      ),
    );

    final result = await _getAnimalDetailUseCase(animalId);
    if (isClosed || revision != _loadRevision) return;
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            detail: ResultState.data(data),
            photo: const ResultState.loading(),
          ),
        );
        _watchLocation(data, revision);
        await _loadPhoto(data, revision);
      case Failure(:final error):
        emit(state.copyWith(detail: ResultState.error(error)));
    }
  }

  void _watchLocation(AnimalDetail animal, int revision) {
    _locationSubscription =
        _watchAnimalLocationUseCase(
          animal.id,
          establishmentId: animal.establishmentId,
        ).listen((result) {
          if (isClosed || revision != _loadRevision) return;
          if (state.detail case Data<AnimalDetail>(:final data)) {
            switch (result) {
              case Success<AnimalLocation?>(data: final location?):
                if (location.animalId != data.id || location.establishmentId != data.establishmentId) return;
                emit(
                  state.copyWith(
                    detail: ResultState.data(
                      data.copyWith(
                        lotId: location.lotId,
                        lotName: location.lotName,
                        updatedAt: location.updatedAt,
                      ),
                    ),
                  ),
                );
              case Success<AnimalLocation?>(data: null):
                emit(
                  state.copyWith(
                    detail: const ResultState.error(
                      DomainException(
                        message: AnimalDetailStrings.animalUnavailable,
                        code: DomainErrorCode.notFound,
                      ),
                    ),
                  ),
                );
              case Failure<AnimalLocation?>():
                // La lectura de fondo ya quedó registrada en data. Conservamos
                // la última ubicación conocida mientras no se pueda releer.
                break;
            }
          }
        });
  }

  Future<void> _loadPhoto(AnimalDetail detail, int revision) async {
    if (isClosed) return;
    final result = await _getAnimalPhotoUseCase(
      establishmentId: detail.establishmentId,
      animalId: detail.id,
    );
    if (isClosed || revision != _loadRevision) return;
    switch (result) {
      case Success<AnimalPhoto?>(:final data):
        emit(state.copyWith(photo: ResultState.data(data)));
      case Failure<AnimalPhoto?>(:final error):
        emit(state.copyWith(photo: ResultState.error(error)));
    }
  }

  @override
  Future<void> close() async {
    _loadRevision++;
    await _locationSubscription?.cancel();
    return super.close();
  }

  /// Vuelve a encolar un alta rechazada y refresca su estado local.
  Future<void> retrySync(String animalId) async {
    if (isClosed) return;
    emit(state.copyWith(detail: const ResultState.loading()));
    final result = await _retryAnimalSyncUseCase(animalId);
    if (isClosed) return;
    switch (result) {
      case Success<void>():
        await loadAnimalData(animalId);
      case Failure<void>(:final error):
        emit(state.copyWith(detail: ResultState.error(error)));
    }
  }
}
