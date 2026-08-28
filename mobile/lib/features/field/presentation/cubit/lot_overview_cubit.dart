import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_field_establishments_use_case.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_lots_use_case.dart';

part 'lot_overview_cubit.freezed.dart';
part 'lot_overview_state.dart';

/// Coordina establecimientos y lotes guardados localmente.
class LotOverviewCubit extends Cubit<LotOverviewState> {
  /// Crea el cubit con consultas offline.
  LotOverviewCubit({
    required GetFieldEstablishmentsUseCase getEstablishments,
    required GetLotsUseCase getLots,
  }) : _getEstablishments = getEstablishments,
       _getLots = getLots,
       super(const LotOverviewState());

  final GetFieldEstablishmentsUseCase _getEstablishments;
  final GetLotsUseCase _getLots;

  /// Carga el catálogo y selecciona el primer establecimiento disponible.
  Future<void> load() async {
    emit(state.copyWith(status: LotOverviewStatus.loading, errorMessage: null));
    final establishmentsResult = await _getEstablishments();
    switch (establishmentsResult) {
      case Success<Map<String, String>>(:final data):
        if (data.isEmpty) {
          emit(state.copyWith(status: LotOverviewStatus.emptyContext, establishments: data));
          return;
        }
        final selected = state.selectedEstablishmentId != null && data.containsKey(state.selectedEstablishmentId)
            ? state.selectedEstablishmentId!
            : data.keys.first;
        emit(state.copyWith(establishments: data, selectedEstablishmentId: selected));
        await _loadLots(selected);
      case Failure<Map<String, String>>(:final error):
        emit(state.copyWith(status: LotOverviewStatus.failure, errorMessage: error.message));
    }
  }

  /// Cambia el establecimiento y reemplaza la colección visible.
  Future<void> selectEstablishment(String establishmentId) async {
    if (!state.establishments.containsKey(establishmentId)) return;
    emit(state.copyWith(selectedEstablishmentId: establishmentId));
    await _loadLots(establishmentId);
  }

  /// Recarga SQLite después de regresar del editor.
  Future<void> refresh() async {
    final selected = state.selectedEstablishmentId;
    if (selected != null) await _loadLots(selected);
  }

  Future<void> _loadLots(String establishmentId) async {
    emit(state.copyWith(status: LotOverviewStatus.loading, errorMessage: null));
    final result = await _getLots(establishmentId);
    switch (result) {
      case Success<List<Lot>>(:final data):
        emit(state.copyWith(status: LotOverviewStatus.ready, lots: data));
      case Failure<List<Lot>>(:final error):
        emit(state.copyWith(status: LotOverviewStatus.failure, errorMessage: error.message));
    }
  }
}
