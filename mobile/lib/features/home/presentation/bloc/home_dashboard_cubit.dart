import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';

/// Coordina la carga del tablero productivo de Inicio.
class HomeDashboardCubit extends Cubit<ResultState<HomeDashboard>> {
  /// Crea el cubit con el caso de uso de indicadores.
  HomeDashboardCubit(this._getHomeDashboardUseCase) : super(const ResultState<HomeDashboard>.initial());

  final GetHomeDashboardUseCase _getHomeDashboardUseCase;

  /// Calcula nuevamente los KPIs usando la informacion offline actual.
  Future<void> load() async {
    emit(const ResultState<HomeDashboard>.loading());
    final result = await _getHomeDashboardUseCase();

    switch (result) {
      case Success<HomeDashboard>(:final data):
        emit(ResultState<HomeDashboard>.data(data));
      case Failure<HomeDashboard>(:final error):
        emit(ResultState<HomeDashboard>.error(error));
    }
  }
}
