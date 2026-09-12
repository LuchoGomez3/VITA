import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_field_establishments_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lot_animal_counts_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lots_use_case.dart';

part 'lot_overview_cubit.freezed.dart';
part 'lot_overview_state.dart';

/// Coordina establecimientos y lotes guardados localmente.
class LotOverviewCubit extends Cubit<LotOverviewState> {
  /// Crea el cubit con consultas offline.
  LotOverviewCubit({
    required GetFieldEstablishmentsUseCase getEstablishments,
    required GetLotsUseCase getLots,
    required GetLotAnimalCountsUseCase getAnimalCounts,
  }) : _getEstablishments = getEstablishments,
       _getLots = getLots,
       _getAnimalCounts = getAnimalCounts,
       super(const LotOverviewState());

  final GetFieldEstablishmentsUseCase _getEstablishments;
  final GetLotsUseCase _getLots;
  final GetLotAnimalCountsUseCase _getAnimalCounts;

  /// Alterna entre el esquema grafico y el listado sin recargar SQLite.
  void showView(LotOverviewView view) {
    emit(state.copyWith(view: view));
  }

  /// Carga el catalogo y selecciona el primer establecimiento disponible.
  Future<void> load() async {
    emit(state.copyWith(loadState: const ResultState.loading()));
    final establishmentsResult = await _getEstablishments();
    switch (establishmentsResult) {
      case Success<Map<String, String>>(:final data):
        if (data.isEmpty) {
          emit(
            state.copyWith(
              loadState: const ResultState.data(null),
              establishments: data,
              selectedEstablishmentId: null,
            ),
          );
          return;
        }
        final selected = state.selectedEstablishmentId != null && data.containsKey(state.selectedEstablishmentId)
            ? state.selectedEstablishmentId!
            : data.keys.first;
        emit(
          state.copyWith(
            establishments: data,
            selectedEstablishmentId: selected,
          ),
        );
        await _loadLots(selected);
      case Failure<Map<String, String>>(:final error):
        emit(state.copyWith(loadState: ResultState.error(error)));
    }
  }

  /// Cambia el establecimiento y reemplaza la coleccion visible.
  Future<void> selectEstablishment(String establishmentId) async {
    if (!state.establishments.containsKey(establishmentId)) return;
    emit(state.copyWith(selectedEstablishmentId: establishmentId));
    await _loadLots(establishmentId);
  }

  /// Recarga SQLite despues de regresar del editor.
  Future<void> refresh() async {
    final selected = state.selectedEstablishmentId;
    if (selected != null) await _loadLots(selected);
  }

  Future<void> _loadLots(String establishmentId) async {
    emit(state.copyWith(loadState: const ResultState.loading()));
    final result = await _getLots(establishmentId);
    switch (result) {
      case Success<List<Lot>>(:final data):
        final countsResult = await _getAnimalCounts(establishmentId);
        switch (countsResult) {
          case Success<Map<String, int>>(data: final counts):
            emit(
              state.copyWith(
                loadState: const ResultState.data(null),
                lots: data,
                animalCounts: counts,
              ),
            );
          case Failure<Map<String, int>>(:final error):
            emit(state.copyWith(loadState: ResultState.error(error)));
        }
      case Failure<List<Lot>>(:final error):
        emit(state.copyWith(loadState: ResultState.error(error)));
    }
  }
}
