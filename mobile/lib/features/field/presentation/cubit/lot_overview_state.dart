part of 'lot_overview_cubit.dart';

/// Estado de carga de la colección local.
enum LotOverviewStatus {
  /// Todavía no comenzó la lectura.
  initial,

  /// Existe una consulta local en curso.
  loading,

  /// La colección local está disponible.
  ready,

  /// No existe ningún establecimiento offline.
  emptyContext,

  /// La lectura local falló.
  failure,
}

/// Estado inmutable del visor de lotes.
@freezed
sealed class LotOverviewState with _$LotOverviewState {
  /// Crea el estado inicial vacío.
  const factory LotOverviewState({
    @Default(LotOverviewStatus.initial) LotOverviewStatus status,
    @Default(<String, String>{}) Map<String, String> establishments,
    String? selectedEstablishmentId,
    @Default(<Lot>[]) List<Lot> lots,
    String? errorMessage,
  }) = _LotOverviewState;
}
