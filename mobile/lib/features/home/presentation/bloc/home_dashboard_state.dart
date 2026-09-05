part of 'home_dashboard_cubit.dart';

/// Estado completo de Inicio.
///
/// Mantiene juntos el resultado asincronico del dashboard y la seleccion de
/// establecimientos para que la UI no dependa de campos mutables del Cubit.
@freezed
abstract class HomeDashboardState with _$HomeDashboardState {
  /// Crea el estado de Inicio con sus valores iniciales.
  const factory HomeDashboardState({
    @Default(ResultState<HomeDashboard>.initial()) ResultState<HomeDashboard> dashboardState,
    @Default(<String, EstablishmentMembership>{}) Map<String, EstablishmentMembership> establishments,
    String? selectedEstablishmentId,
  }) = _HomeDashboardState;
}
