import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_animal_list_use_case.dart';

part 'animal_list_cubit.freezed.dart';
part 'animal_list_state.dart';

/// Coordina la lista de animales: carga local, búsqueda y filtro por categoría.
class AnimalListCubit extends Cubit<AnimalListState> {
  /// Crea el cubit con el caso de uso que lee los animales locales.
  AnimalListCubit({
    required GetAnimalListUseCase getAnimalListUseCase,
    required GetAnimalListEstablishmentsUseCase getEstablishmentsUseCase,
  }) : _getAnimalListUseCase = getAnimalListUseCase,
       _getEstablishmentsUseCase = getEstablishmentsUseCase,
       super(const AnimalListState());

  final GetAnimalListUseCase _getAnimalListUseCase;
  final GetAnimalListEstablishmentsUseCase _getEstablishmentsUseCase;

  /// Lee los animales guardados en el celular.
  ///
  /// En una recarga (por ejemplo, al volver de un alta) mantiene la lista
  /// anterior en pantalla mientras lee, en lugar de mostrar la carga.
  Future<void> load() async {
    if (state.animals is! Data<List<AnimalListEntry>>) {
      emit(state.copyWith(animals: const ResultState.loading()));
    }
    await _loadEstablishments();
    final result = await _getAnimalListUseCase();
    switch (result) {
      case Success<List<AnimalListEntry>>(:final data):
        emit(state.copyWith(animals: ResultState.data(data)));
      case Failure<List<AnimalListEntry>>(:final error):
        emit(state.copyWith(animals: ResultState.error(error)));
    }
  }

  /// Lee los establecimientos y, la primera vez, elige uno.
  ///
  /// Con un solo establecimiento queda elegido; con varios arranca en "Todos".
  /// Si el elegido ya no está (por ejemplo, se perdió el acceso), vuelve a
  /// "Todos".
  Future<void> _loadEstablishments() async {
    final result = await _getEstablishmentsUseCase();
    if (result case Success<List<EstablishmentMembership>>(:final data)) {
      final current = state.establishmentId;
      final keepsCurrent = current != null && data.any((establishment) => establishment.id == current);
      emit(
        state.copyWith(
          establishments: data,
          establishmentId: keepsCurrent ? current : (data.length == 1 ? data.single.id : null),
        ),
      );
    }
  }

  /// Elige un establecimiento, o `null` para ver todos. Limpia la categoría,
  /// que puede no existir en el otro campo.
  void selectEstablishment(String? establishmentId) =>
      emit(state.copyWith(establishmentId: establishmentId, category: null));

  /// Actualiza el texto buscado.
  void search(String query) => emit(state.copyWith(query: query));

  /// Elige una categoría, o `null` para ver todos.
  void selectCategory(String? category) => emit(state.copyWith(category: category));
}
