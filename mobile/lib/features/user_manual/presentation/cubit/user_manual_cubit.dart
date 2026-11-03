import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';
import 'package:frontend_mayoral/features/user_manual/domain/use_cases/get_user_manual_use_case.dart';

/// Carga el manual filtrado por el rol de la persona.
class UserManualCubit extends Cubit<ResultState<UserManual>> {
  /// Crea el Cubit.
  UserManualCubit(this._getUserManual) : super(const ResultState.initial());

  final GetUserManualUseCase _getUserManual;

  /// Lee el manual de los assets y lo filtra.
  Future<void> load() async {
    emit(const ResultState.loading());
    final result = await _getUserManual();
    if (isClosed) return;
    switch (result) {
      case Success<UserManual>(:final data):
        emit(ResultState.data(data));
      case Failure<UserManual>(:final error):
        emit(ResultState.error(error));
    }
  }
}
