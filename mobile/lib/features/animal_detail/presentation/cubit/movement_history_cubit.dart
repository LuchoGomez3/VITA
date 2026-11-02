import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_movement_history_use_case.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';

/// Carga el historial de potreros de un animal.
class MovementHistoryCubit extends Cubit<ResultState<List<MovementHistoryEntry>>> {
  /// Crea el cubit.
  MovementHistoryCubit(this._getHistory) : super(const ResultState.initial());

  final GetAnimalMovementHistoryUseCase _getHistory;

  /// Lee el historial de [animalId].
  Future<void> load(String animalId) async {
    final result = await _getHistory(animalId);
    if (isClosed) return;
    switch (result) {
      case Success<List<MovementHistoryEntry>>(:final data):
        emit(ResultState.data(data));
      case Failure<List<MovementHistoryEntry>>(:final error):
        emit(ResultState.error(error));
    }
  }
}
