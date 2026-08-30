part of 'lot_overview_cubit.dart';

/// Modo elegido para consultar los lotes.
enum LotOverviewView {
  /// Lienzo esquematico local.
  schematic,

  /// Tarjetas tabuladas.
  list,
}

/// Estado inmutable del visor de lotes.
@freezed
sealed class LotOverviewState with _$LotOverviewState {
  /// Crea el estado inicial vacio.
  const factory LotOverviewState({
    @Default(ResultState<void>.initial()) ResultState<void> loadState,
    @Default(<String, String>{}) Map<String, String> establishments,
    String? selectedEstablishmentId,
    @Default(<Lot>[]) List<Lot> lots,
    @Default(<String, int>{}) Map<String, int> animalCounts,
    @Default(LotOverviewView.schematic) LotOverviewView view,
  }) = _LotOverviewState;
}
