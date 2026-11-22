import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:frontend_mayoral/features/feeding/domain/use_cases/feeding_use_cases.dart';

/// Carga la alimentación de un animal y la relee cuando cambian sus datos
/// locales (un movimiento, un recurso del potrero o un registro nuevo).
class AnimalFeedingCubit extends Cubit<ResultState<AnimalFeedingHistory>> {
  /// Crea el cubit.
  AnimalFeedingCubit(this._getHistory) : super(const ResultState.initial()) {
    _subscription = _getHistory.changes.listen((_) {
      final animalId = _animalId;
      if (animalId != null) unawaited(load(animalId));
    });
  }

  final GetAnimalFeedingHistoryUseCase _getHistory;
  late final StreamSubscription<void> _subscription;
  String? _animalId;
  int _readRevision = 0;

  /// Lee el historial de [animalId].
  Future<void> load(String animalId) async {
    _animalId = animalId;
    final revision = ++_readRevision;
    final result = await _getHistory(animalId);
    // Una lectura iniciada antes no debe pisar una más nueva.
    if (isClosed || revision != _readRevision) return;
    switch (result) {
      case Success<AnimalFeedingHistory>(:final data):
        emit(ResultState.data(data));
      case Failure<AnimalFeedingHistory>(:final error):
        emit(ResultState.error(error));
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
