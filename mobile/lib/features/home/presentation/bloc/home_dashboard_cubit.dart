import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';

/// Coordina la carga del tablero productivo de Inicio.
class HomeDashboardCubit extends Cubit<ResultState<HomeDashboard>> {
  /// Crea el cubit con el caso de uso de indicadores.
  HomeDashboardCubit({
    required GetHomeDashboardUseCase getHomeDashboardUseCase,
    required GetHomeEstablishmentsUseCase getHomeEstablishmentsUseCase,
  }) : _getHomeDashboardUseCase = getHomeDashboardUseCase,
       _getHomeEstablishmentsUseCase = getHomeEstablishmentsUseCase,
       super(const ResultState<HomeDashboard>.initial());

  final GetHomeDashboardUseCase _getHomeDashboardUseCase;
  final GetHomeEstablishmentsUseCase _getHomeEstablishmentsUseCase;

  Map<String, String> _establishments = const {};
  String? _selectedEstablishmentId;

  /// Establecimientos disponibles para el selector de Inicio.
  Map<String, String> get establishments => _establishments;

  /// ID seleccionado; `null` representa todos los establecimientos.
  String? get selectedEstablishmentId => _selectedEstablishmentId;

  /// Calcula nuevamente los KPIs usando la informacion offline actual.
  Future<void> load() async {
    emit(const ResultState<HomeDashboard>.loading());
    final establishmentsResult = await _getHomeEstablishmentsUseCase();
    switch (establishmentsResult) {
      case Success<Map<String, String>>(:final data):
        _establishments = data;
      case Failure<Map<String, String>>(:final error):
        emit(ResultState<HomeDashboard>.error(error));
        return;
    }

    await _loadDashboard();
  }

  /// Cambia el establecimiento activo y vuelve a calcular los indicadores.
  Future<void> selectEstablishment(String? establishmentId) async {
    if (establishmentId != null &&
        !_establishments.containsKey(establishmentId)) {
      return;
    }

    _selectedEstablishmentId = establishmentId;
    emit(const ResultState<HomeDashboard>.loading());
    await _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final selectedId = _selectedEstablishmentId;
    final result = await _getHomeDashboardUseCase(
      establishmentIds: selectedId == null ? null : {selectedId},
    );
    switch (result) {
      case Success<HomeDashboard>(:final data):
        emit(ResultState<HomeDashboard>.data(data));
      case Failure<HomeDashboard>(:final error):
        emit(ResultState<HomeDashboard>.error(error));
    }
  }
}
