// Archivo: features/animal_detail/presentation/cubit/animal_detail_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'animal_detail_state.dart';

class AnimalDetailCubit extends Cubit<AnimalDetailState> {
  
  // Arranca en estado inicial
  AnimalDetailCubit() : super(AnimalDetailInitial());

  // Función pública que la vista llama para pedir los datos
  Future<void> loadAnimalData(String animalId) async {
    emit(AnimalDetailLoading());

    try {
      // Aquí irá la petición a tu base de datos/API
      await Future.delayed(const Duration(seconds: 2)); // Simulación

      // Emitimos el estado con los datos cargados
      emit(AnimalDetailLoaded(
        raza: 'Brahman',
        sexo: 'Macho',
        categoria: 'Novillo',
        pesoActual: 410,
      ));

    } catch (e) {
      emit(AnimalDetailError("Error al cargar la información del animal."));
    }
  }
}