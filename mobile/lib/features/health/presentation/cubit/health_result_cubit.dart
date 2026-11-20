import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_registration_cubit.dart';

/// Guarda el primer resultado desde su ficha.
class HealthResultCubit extends Cubit<ResultState<void>> {
  /// Crea el cubit de carga de resultado.
  HealthResultCubit(this._record) : super(const ResultState.initial());

  final RecordHealthResultUseCase _record;

  /// Guarda el resultado o devuelve una falla legible.
  Future<void> save(HealthEvent event, String value, DateTime date) async {
    if (state is Loading<void>) return;
    emit(const ResultState.loading());
    try {
      await _record(event, value, date);
      if (!isClosed) emit(const ResultState.data(null));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      if (!isClosed) emit(ResultState.error(healthFormError(error)));
    }
  }
}
