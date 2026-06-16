// Archivo: animal_detail_state.dart

abstract class AnimalDetailState {}

class AnimalDetailInitial extends AnimalDetailState {}

class AnimalDetailLoading extends AnimalDetailState {}

class AnimalDetailLoaded extends AnimalDetailState {
  final String raza;
  final String sexo;
  final int pesoActual;
  final String categoria;

  AnimalDetailLoaded({
    required this.raza, 
    required this.sexo, 
    required this.pesoActual,
    required this.categoria,
  });
}

class AnimalDetailError extends AnimalDetailState {
  final String message;
  AnimalDetailError(this.message);
}