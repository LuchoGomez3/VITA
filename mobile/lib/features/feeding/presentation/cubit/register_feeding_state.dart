part of 'register_feeding_cubit.dart';

/// Cuánto dura el suministro.
enum FeedingDuration {
  /// Un solo día.
  oneDay,

  /// Entre dos fechas.
  period,

  /// Sigue vigente.
  ongoing,
}

/// Estado del formulario "Registrar alimentación".
@freezed
sealed class RegisterFeedingState with _$RegisterFeedingState {
  /// Crea el estado.
  const factory RegisterFeedingState({
    @Default(ResultState<FeedingFormData>.initial()) ResultState<FeedingFormData> preparation,
    @Default('') String establishmentId,
    @Default(<FeedingAnimal>[]) List<FeedingAnimal> animals,
    @Default(<Food>[]) List<Food> foods,
    @Default(<FeedingLot>[]) List<FeedingLot> lots,
    @Default(FeedingType.supplement) FeedingType type,
    String? foodId,
    NewFoodInput? newFood,
    String? lotId,
    @Default('kg') String unitCode,
    @Default(FeedingQuantityBasis.perAnimalDay) FeedingQuantityBasis basis,
    @Default(FeedingDuration.oneDay) FeedingDuration duration,
    DateTime? startDate,
    DateTime? endDate,
    @Default(ResultState<FeedingAnimal>.initial()) ResultState<FeedingAnimal> tagResolution,
    @Default(ResultState<int>.initial()) ResultState<int> submission,
  }) = _RegisterFeedingState;

  const RegisterFeedingState._();

  /// Hay un alimento elegido (del catálogo o nuevo).
  bool get hasFood => foodId != null || newFood != null;

  /// Se está guardando.
  bool get isSaving => submission is Loading<int>;
}
