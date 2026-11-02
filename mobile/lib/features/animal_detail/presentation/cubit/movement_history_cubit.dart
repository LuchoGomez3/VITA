import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_movement_history_use_case.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';

/// Carga el historial de potreros de un animal.
class MovementHistoryCubit extends Cubit<ResultState<List<MovementHistoryEntry>>> {
  /// Crea el cubit.
  MovementHistoryCubit(this._getHistory) : super(const ResultState.initial()) {
    _subscription = _getHistory.changes.listen((_) {
      final animalId = _animalId;
      if (animalId != null) unawaited(load(animalId));
    });
  }

  final GetAnimalMovementHistoryUseCase _getHistory;
  late final StreamSubscription<void> _subscription;
  String? _animalId;
  int _readRevision = 0;

  /// Lee el historial de [animalId].
  Future<void> load(String animalId) async {
    _animalId = animalId;
    final revision = ++_readRevision;
    final result = await _getHistory(animalId);
    // Una lectura iniciada antes de la reconciliación no debe pisar la nueva.
    if (isClosed || revision != _readRevision) return;
    switch (result) {
      case Success<List<MovementHistoryEntry>>(:final data):
        emit(ResultState.data(data));
      case Failure<List<MovementHistoryEntry>>(:final error):
        emit(ResultState.error(error));
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
