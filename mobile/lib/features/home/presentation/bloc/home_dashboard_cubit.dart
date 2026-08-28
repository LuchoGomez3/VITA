import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';

part 'home_dashboard_cubit.freezed.dart';
part 'home_dashboard_state.dart';

/// Coordina la carga del tablero productivo de Inicio.
class HomeDashboardCubit extends Cubit<HomeDashboardState> {
  /// Crea el cubit con el caso de uso de indicadores.
  HomeDashboardCubit({
    required GetHomeDashboardUseCase getHomeDashboardUseCase,
    required GetHomeEstablishmentsUseCase getHomeEstablishmentsUseCase,
  }) : _getHomeDashboardUseCase = getHomeDashboardUseCase,
       _getHomeEstablishmentsUseCase = getHomeEstablishmentsUseCase,
       super(const HomeDashboardState());

  final GetHomeDashboardUseCase _getHomeDashboardUseCase;
  final GetHomeEstablishmentsUseCase _getHomeEstablishmentsUseCase;

  /// Calcula nuevamente los KPIs usando la informacion offline actual.
  Future<void> load() async {
    emit(
      state.copyWith(
        dashboardState: const ResultState<HomeDashboard>.loading(),
      ),
    );
    final establishmentsResult = await _getHomeEstablishmentsUseCase();
    switch (establishmentsResult) {
      case Success<Map<String, EstablishmentMembership>>(:final data):
        emit(state.copyWith(establishments: data));
      case Failure<Map<String, EstablishmentMembership>>(:final error):
        emit(
          state.copyWith(
            dashboardState: ResultState<HomeDashboard>.error(error),
          ),
        );
        return;
    }

    await _loadDashboard();
  }

  /// Cambia el establecimiento activo y vuelve a calcular los indicadores.
  Future<void> selectEstablishment(String? establishmentId) async {
    final hasEstablishment = state.establishments.containsKey(establishmentId);
    final isUnknownEstablishment = establishmentId != null && !hasEstablishment;
    if (isUnknownEstablishment) {
      return;
    }

    emit(
      state.copyWith(
        selectedEstablishmentId: establishmentId,
        dashboardState: const ResultState<HomeDashboard>.loading(),
      ),
    );
    await _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final selectedId = state.selectedEstablishmentId;
    final result = await _getHomeDashboardUseCase(
      establishmentIds: selectedId == null ? null : {selectedId},
    );
    switch (result) {
      case Success<HomeDashboard>(:final data):
        emit(
          state.copyWith(
            dashboardState: ResultState<HomeDashboard>.data(data),
          ),
        );
      case Failure<HomeDashboard>(:final error):
        emit(
          state.copyWith(
            dashboardState: ResultState<HomeDashboard>.error(error),
          ),
        );
    }
  }
}
