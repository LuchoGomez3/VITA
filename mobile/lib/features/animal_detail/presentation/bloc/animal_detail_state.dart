/// Base state for the animal detail view.
abstract class AnimalDetailState {}

/// Initial state before the detail loading starts.
class AnimalDetailInitial extends AnimalDetailState {}

/// State emitted while the animal detail is loading.
class AnimalDetailLoading extends AnimalDetailState {}

/// Loaded animal detail state.
class AnimalDetailLoaded extends AnimalDetailState {
  /// Creates loaded mock animal detail data.
  AnimalDetailLoaded({
    required this.raza,
    required this.sexo,
    required this.pesoActual,
    required this.categoria,
  });

  /// Animal breed.
  final String raza;

  /// Animal sex.
  final String sexo;

  /// Current animal weight in kilograms.
  final int pesoActual;

  /// Animal category.
  final String categoria;
}

/// State emitted when the animal detail cannot be loaded.
class AnimalDetailError extends AnimalDetailState {
  /// Creates an error state with a user-facing [message].
  AnimalDetailError(this.message);

  /// User-facing error message.
  final String message;
}
