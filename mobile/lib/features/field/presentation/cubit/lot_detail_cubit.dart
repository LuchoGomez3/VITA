import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/delete_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_available_destination_lots_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_animals_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';
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
  }) : _lotId = lotId,
       _getLot = getLot,
       _getAvailableDestinations = getAvailableDestinations,
       _getAnimals = getAnimals,
       _moveAnimals = moveAnimals,
       _updateLot = updateLot,
       _deleteLot = deleteLot,
       super(const LotDetailState());

  final String _lotId;
  final GetLotUseCase _getLot;
  final GetAvailableDestinationLotsUseCase _getAvailableDestinations;
  final GetLotAnimalsUseCase _getAnimals;
  final MoveLotAnimalsUseCase _moveAnimals;
  final UpdateLotDetailsUseCase _updateLot;
  final DeleteLotUseCase _deleteLot;

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
    String? forageResourceCode,
  }) async {
    emit(state.copyWith(mutationState: const ResultState.loading()));
    final result = await _updateLot(
      lotId: _lotId,
      name: name,
      surfaceTenths: surfaceTenths,
      forageResourceCode: forageResourceCode,
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
}
