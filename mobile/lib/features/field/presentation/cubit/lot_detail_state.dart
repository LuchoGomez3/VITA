part of 'lot_detail_cubit.dart';

/// Estado inmutable de detalle y sus mutaciones.
@freezed
sealed class LotDetailState with _$LotDetailState {
  /// Crea el estado inicial.
  const factory LotDetailState({
    @Default(ResultState<void>.initial()) ResultState<void> loadState,
    @Default(ResultState<void>.initial()) ResultState<void> mutationState,
    Lot? lot,
    @Default(<LotAnimalSummary>[]) List<LotAnimalSummary> animals,
    @Default(ResultState<List<Lot>>.initial()) ResultState<List<Lot>> destinationsState,
    @Default(false) bool isDeleted,
  }) = _LotDetailState;

  const LotDetailState._();

  /// Indica si una edicion, eliminacion o movimiento esta en curso.
  bool get isSaving => mutationState is Loading<void>;

  /// Destinos disponibles cuando su lectura local fue exitosa.
  List<Lot> get availableDestinations => switch (destinationsState) {
    Data<List<Lot>>(:final data) => data,
    _ => const [],
  };

  /// Mensaje de la ultima mutacion fallida, si existe.
  String? get mutationErrorMessage => switch (mutationState) {
    ResultError<void>(:final error) => error.message,
    _ => null,
  };
}
