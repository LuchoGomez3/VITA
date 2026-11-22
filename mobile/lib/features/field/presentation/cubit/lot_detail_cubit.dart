import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/delete_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_available_destination_lots_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_animals_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_forage_periods_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/save_lot_forage_period_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/update_lot_details_use_case.dart';

part 'lot_detail_cubit.freezed.dart';
part 'lot_detail_state.dart';

/// Coordina la ficha local, sus animales y las mutaciones permitidas.
class LotDetailCubit extends Cubit<LotDetailState> {
  /// Crea el estado de detalle con casos de uso offline.
  LotDetailCubit({
    required String lotId,
    required GetLotUseCase getLot,
    required GetAvailableDestinationLotsUseCase getAvailableDestinations,
    required GetLotAnimalsUseCase getAnimals,
    required MoveLotAnimalsUseCase moveAnimals,
    required UpdateLotDetailsUseCase updateLot,
    required DeleteLotUseCase deleteLot,
    required GetLotForagePeriodsUseCase getForagePeriods,
    required SaveLotForagePeriodUseCase saveForagePeriod,
  }) : _lotId = lotId,
       _getForagePeriods = getForagePeriods,
       _saveForagePeriod = saveForagePeriod,
       _getLot = getLot,
       _getAvailableDestinations = getAvailableDestinations,
       _getAnimals = getAnimals,
       _moveAnimals = moveAnimals,
       _updateLot = updateLot,
       _deleteLot = deleteLot,
       super(const LotDetailState()) {
    // La confirmación del servidor llega después de guardar: se relee solo el
    // historial para que el chip "Pendiente" se actualice sin recargar todo.
    _periodChanges = _getForagePeriods.changes.listen((_) => unawaited(_reloadForagePeriods()));
  }

  late final StreamSubscription<void> _periodChanges;

  final String _lotId;
  final GetLotUseCase _getLot;
  final GetAvailableDestinationLotsUseCase _getAvailableDestinations;
  final GetLotAnimalsUseCase _getAnimals;
  final MoveLotAnimalsUseCase _moveAnimals;
  final UpdateLotDetailsUseCase _updateLot;
  final DeleteLotUseCase _deleteLot;
  final GetLotForagePeriodsUseCase _getForagePeriods;
  final SaveLotForagePeriodUseCase _saveForagePeriod;

  /// Carga lote y animales desde SQLite.
  Future<void> load() async {
    emit(state.copyWith(loadState: const ResultState.loading()));
    final lotResult = await _getLot(_lotId);
    switch (lotResult) {
      case Failure<Lot>(:final error):
        emit(state.copyWith(loadState: ResultState.error(error)));
      case Success<Lot>(:final data):
        final destinationsResult = await _getAvailableDestinations(
          establishmentId: data.establishmentId,
          sourceLotId: data.id,
        );
        final animalsResult = await _getAnimals(
          establishmentId: data.establishmentId,
          lotId: data.id,
        );
        final periodsResult = await _getForagePeriods(
          establishmentId: data.establishmentId,
          lotId: data.id,
        );
        switch (animalsResult) {
          case Success<List<LotAnimalSummary>>(data: final animals):
            final destinationsState = destinationsResult is Success<List<Lot>>
                ? ResultState<List<Lot>>.data(destinationsResult.data)
                : ResultState<List<Lot>>.error(
                    (destinationsResult as Failure<List<Lot>>).error,
                  );
            emit(
              state.copyWith(
                loadState: const ResultState.data(null),
                mutationState: const ResultState.initial(),
                lot: data,
                animals: animals,
                destinationsState: destinationsState,
                foragePeriodsState: periodsResult is Success<List<LotForagePeriod>>
                    ? ResultState<List<LotForagePeriod>>.data(periodsResult.data)
                    : ResultState<List<LotForagePeriod>>.error(
                        (periodsResult as Failure<List<LotForagePeriod>>).error,
                      ),
              ),
            );
          case Failure<List<LotAnimalSummary>>(:final error):
            emit(state.copyWith(loadState: ResultState.error(error)));
        }
    }
  }

  /// Edita los campos alfanumericos y vuelve a cargar la ficha.
  Future<void> update({
    required String name,
    required int surfaceTenths,
    required bool hasWater,
    required LotStatus status,
  }) async {
    emit(state.copyWith(mutationState: const ResultState.loading()));
    final result = await _updateLot(
      lotId: _lotId,
      name: name,
      surfaceTenths: surfaceTenths,
      hasWater: hasWater,
      status: status,
    );
    switch (result) {
      case Success<Lot>():
        await load();
      case Failure<Lot>(:final error):
        emit(state.copyWith(mutationState: ResultState.error(error)));
    }
  }

  /// Solicita el borrado logico del lote vacio.
  Future<void> delete() async {
    emit(state.copyWith(mutationState: const ResultState.loading()));
    final result = await _deleteLot(_lotId);
    switch (result) {
      case Success<Lot>():
        emit(
          state.copyWith(
            isDeleted: true,
            mutationState: const ResultState.data(null),
          ),
        );
      case Failure<Lot>(:final error):
        emit(state.copyWith(mutationState: ResultState.error(error)));
    }
  }

  /// Traslada los animales seleccionados a otro lote activo y recarga la ficha.
  Future<void> moveAnimals({
    required List<String> animalIds,
    required String destinationLotId,
    required DateTime occurredAt,
    required String reason,
  }) async {
    final lot = state.lot;
    if (lot == null) return;
    emit(state.copyWith(mutationState: const ResultState.loading()));
    final result = await _moveAnimals(
      establishmentId: lot.establishmentId,
      sourceLotId: lot.id,
      destinationLotId: destinationLotId,
      animalIds: animalIds,
      occurredAt: occurredAt,
      reason: reason,
    );
    switch (result) {
      case Success():
        await load();
      case Failure(:final error):
        emit(state.copyWith(mutationState: ResultState.error(error)));
    }
  }

  /// Registra un recurso nuevo del potrero o corrige [existing], y recarga.
  Future<void> saveForagePeriod({
    required String resourceCode,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
    LotForagePeriod? existing,
  }) async {
    final lot = state.lot;
    if (lot == null) return;
    emit(state.copyWith(mutationState: const ResultState.loading()));
    final result = await _saveForagePeriod(
      establishmentId: lot.establishmentId,
      lotId: lot.id,
      resourceCode: resourceCode,
      startDate: startDate,
      endDate: endDate,
      description: description,
      existing: existing,
    );
    switch (result) {
      case Success():
        await load();
      case Failure(:final error):
        emit(state.copyWith(mutationState: ResultState.error(error)));
    }
  }

  /// Borra lógicamente un período del historial y recarga.
  Future<void> deleteForagePeriod(LotForagePeriod period) async {
    emit(state.copyWith(mutationState: const ResultState.loading()));
    final result = await _saveForagePeriod.delete(period);
    switch (result) {
      case Success():
        await load();
      case Failure(:final error):
        emit(state.copyWith(mutationState: ResultState.error(error)));
    }
  }

  Future<void> _reloadForagePeriods() async {
    final lot = state.lot;
    if (lot == null || isClosed) return;
    final result = await _getForagePeriods(establishmentId: lot.establishmentId, lotId: lot.id);
    if (isClosed) return;
    if (result case Success<List<LotForagePeriod>>(:final data)) {
      emit(state.copyWith(foragePeriodsState: ResultState.data(data)));
    }
  }

  @override
  Future<void> close() async {
    await _periodChanges.cancel();
    return super.close();
  }
}
