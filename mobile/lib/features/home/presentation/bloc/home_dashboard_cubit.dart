import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
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
    PreparePostAuthentication? refreshOfflineData,
    Stream<Result<PostAuthenticationSummary>>? syncResults,
    Stream<bool>? connectivityChanges,
    void Function()? onClose,
  }) : _getHomeDashboardUseCase = getHomeDashboardUseCase,
       _getHomeEstablishmentsUseCase = getHomeEstablishmentsUseCase,
       _refreshOfflineData = refreshOfflineData,
       _onClose = onClose,
       super(const HomeDashboardState()) {
    _connectivitySubscription = connectivityChanges?.listen((isConnected) {
      if (isConnected) unawaited(refresh());
    });
    _syncResultSubscription = syncResults?.listen((result) {
      if (!_refreshInProgress) unawaited(_applyExternalSyncResult(result));
    });
  }

  final GetHomeDashboardUseCase _getHomeDashboardUseCase;
  final GetHomeEstablishmentsUseCase _getHomeEstablishmentsUseCase;
  final PreparePostAuthentication? _refreshOfflineData;
  final void Function()? _onClose;
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<Result<PostAuthenticationSummary>>? _syncResultSubscription;
  bool _refreshInProgress = false;

  /// Muestra primero la cache y luego intenta actualizarla sin bloquear la UI.
  Future<void> initialize() async {
    await load();
    if (isClosed) return;
    if (_refreshOfflineData != null) unawaited(refresh());
  }

  /// Calcula nuevamente los KPIs usando la informacion offline actual.
  Future<void> load() async {
    if (isClosed) return;
    emit(
      state.copyWith(
        dashboardState: const ResultState<HomeDashboard>.loading(),
      ),
    );
    final establishmentsResult = await _getHomeEstablishmentsUseCase();
    if (isClosed) return;
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

  /// Sincroniza con backend y vuelve a calcular desde SQLite.
  ///
  /// La cache ya visible nunca se reemplaza por un loading ni se descarta ante
  /// una falla de red. El error queda separado para que presentation lo informe.
  Future<void> refresh() async {
    if (isClosed || _refreshInProgress) return;
    final refreshOfflineData = _refreshOfflineData;
    if (refreshOfflineData == null) {
      await _loadDashboard();
      return;
    }

    _refreshInProgress = true;
    emit(state.copyWith(isRefreshing: true, refreshError: null));
    DomainException? refreshError;
    try {
      final syncResult = await refreshOfflineData();
      if (isClosed) return;
      refreshError = switch (syncResult) {
        Failure<PostAuthenticationSummary>(:final error) => error,
        _ => null,
      };

      final establishmentsResult = await _getHomeEstablishmentsUseCase();
      if (isClosed) return;
      switch (establishmentsResult) {
        case Success<Map<String, EstablishmentMembership>>(:final data):
          emit(state.copyWith(establishments: data));
        case Failure<Map<String, EstablishmentMembership>>(:final error):
          refreshError ??= error;
      }
      await _loadDashboard();
    } on Object {
      refreshError = const DomainException(
        message: 'No se pudieron actualizar los datos. La cache sigue disponible.',
        code: DomainErrorCode.syncFailed,
      );
    } finally {
      _refreshInProgress = false;
      if (!isClosed) {
        emit(
          state.copyWith(
            isRefreshing: false,
            refreshError: refreshError,
          ),
        );
      }
    }
  }

  Future<void> _applyExternalSyncResult(
    Result<PostAuthenticationSummary> result,
  ) async {
    if (isClosed) return;
    final refreshError = switch (result) {
      Failure<PostAuthenticationSummary>(:final error) => error,
      _ => null,
    };
    final establishmentsResult = await _getHomeEstablishmentsUseCase();
    if (isClosed) return;
    if (establishmentsResult case Success<Map<String, EstablishmentMembership>>(:final data)) {
      emit(state.copyWith(establishments: data));
    }
    await _loadDashboard();
    if (!isClosed) emit(state.copyWith(refreshError: refreshError));
  }

  /// Cambia el establecimiento activo y vuelve a calcular los indicadores.
  Future<void> selectEstablishment(String? establishmentId) async {
    if (isClosed) return;
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
    if (isClosed) return;
    final selectedId = state.selectedEstablishmentId;
    final result = await _getHomeDashboardUseCase(
      establishmentIds: selectedId == null ? null : {selectedId},
    );
    if (isClosed) return;
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

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    await _syncResultSubscription?.cancel();
    _onClose?.call();
    return super.close();
  }
}
