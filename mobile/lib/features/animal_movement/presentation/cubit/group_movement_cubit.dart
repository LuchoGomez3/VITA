import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';
import 'package:meta/meta.dart';

/// Estado de "Mover animales".
@immutable
class GroupMovementState {
  /// Crea el estado.
  const GroupMovementState({
    this.isLoading = true,
    this.loadError,
    this.establishmentId = '',
    this.animals = const [],
    this.destinations = const [],
    this.destinationId,
    this.occurredAt,
    this.tagError,
    this.submitError,
    this.isSubmitting = false,
    this.summary,
  });

  /// Cargando el animal inicial y los potreros.
  final bool isLoading;

  /// No se pudo abrir la pantalla.
  final String? loadError;

  /// Campo de los animales (no se mezclan establecimientos).
  final String establishmentId;

  /// Animales leídos, en el orden en que se agregaron.
  final List<MovementAnimal> animals;

  /// Potreros activos del campo.
  final List<MovementDestination> destinations;

  /// Potrero elegido.
  final String? destinationId;

  /// Fecha del movimiento; `null` es ahora.
  final DateTime? occurredAt;

  /// Error de la última caravana leída.
  final String? tagError;

  /// Error al registrar el movimiento.
  final String? submitError;

  /// Guardando.
  final bool isSubmitting;

  /// Resultado: cuando no es `null` la pantalla se cierra.
  final GroupMovementSummary? summary;

  /// Nombre del destino elegido.
  String get destinationName =>
      destinations.where((lot) => lot.id == destinationId).map((lot) => lot.name).firstOrNull ?? '';

  /// Animales que cambiarían de potrero con el destino elegido.
  int get movableCount => animals.where((animal) => animal.lotId != destinationId).length;

  GroupMovementState _copy({
    bool? isLoading,
    Object? loadError = _keep,
    String? establishmentId,
    List<MovementAnimal>? animals,
    List<MovementDestination>? destinations,
    Object? destinationId = _keep,
    Object? occurredAt = _keep,
    Object? tagError = _keep,
    Object? submitError = _keep,
    bool? isSubmitting,
    Object? summary = _keep,
  }) => GroupMovementState(
    isLoading: isLoading ?? this.isLoading,
    loadError: identical(loadError, _keep) ? this.loadError : loadError as String?,
    establishmentId: establishmentId ?? this.establishmentId,
    animals: animals ?? this.animals,
    destinations: destinations ?? this.destinations,
    destinationId: identical(destinationId, _keep) ? this.destinationId : destinationId as String?,
    occurredAt: identical(occurredAt, _keep) ? this.occurredAt : occurredAt as DateTime?,
    tagError: identical(tagError, _keep) ? this.tagError : tagError as String?,
    submitError: identical(submitError, _keep) ? this.submitError : submitError as String?,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    summary: identical(summary, _keep) ? this.summary : summary as GroupMovementSummary?,
  );

  static const _keep = Object();
}

/// Arma la lista de animales leyendo caravanas y registra el movimiento.
class GroupMovementCubit extends Cubit<GroupMovementState> {
  /// Crea el cubit.
  GroupMovementCubit({
    required PrepareGroupMovementUseCase prepare,
    required ResolveMovementTagUseCase resolveTag,
    required RegisterGroupMovementUseCase register,
  }) : _prepare = prepare,
       _resolveTag = resolveTag,
       _register = register,
       super(const GroupMovementState());

  final PrepareGroupMovementUseCase _prepare;
  final ResolveMovementTagUseCase _resolveTag;
  final RegisterGroupMovementUseCase _register;

  /// Arranca con [animalIds] ya en la lista.
  Future<void> start(List<String> animalIds) async {
    final result = await _prepare(animalIds);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(
          state._copy(
            isLoading: false,
            establishmentId: data.animals.first.establishmentId,
            animals: data.animals,
            destinations: data.destinations,
          ),
        );
      case Failure(:final error):
        emit(state._copy(isLoading: false, loadError: error.message));
    }
  }

  /// Agrega el animal de [tag] (lectura del bastón o texto escrito).
  ///
  /// Devuelve si se agregó, para que la pantalla limpie el campo.
  Future<bool> addTag(String tag) async {
    final result = await _resolveTag(
      tag: tag,
      establishmentId: state.establishmentId,
      selectedIds: {for (final animal in state.animals) animal.id},
    );
    if (isClosed) return false;
    switch (result) {
      case Success<MovementAnimal>(:final data):
        emit(state._copy(animals: [...state.animals, data], tagError: null, submitError: null));
        return true;
      case Failure<MovementAnimal>(:final error):
        emit(state._copy(tagError: error.message));
        return false;
    }
    return false;
  }

  /// Saca un animal de la lista.
  void remove(String animalId) {
    emit(
      state._copy(
        animals: [
          for (final animal in state.animals)
            if (animal.id != animalId) animal,
        ],
      ),
    );
  }

  /// Elige el potrero de destino.
  void selectDestination(String lotId) => emit(state._copy(destinationId: lotId, submitError: null));

  /// Cambia la fecha del movimiento.
  void selectDate(DateTime date) => emit(state._copy(occurredAt: date));

  /// Registra el movimiento con [reason].
  Future<void> submit(String reason) async {
    final destinationId = state.destinationId;
    if (destinationId == null) {
      emit(state._copy(submitError: 'Elegí el potrero de destino.'));
      return;
    }
    emit(state._copy(isSubmitting: true, submitError: null));
    final result = await _register(
      establishmentId: state.establishmentId,
      animals: state.animals,
      destinationLotId: destinationId,
      occurredAt: state.occurredAt ?? DateTime.now(),
      reason: reason,
    );
    if (isClosed) return;
    switch (result) {
      case Success<GroupMovementSummary>(:final data):
        emit(state._copy(isSubmitting: false, summary: data));
      case Failure<GroupMovementSummary>(:final error):
        emit(state._copy(isSubmitting: false, submitError: error.message));
    }
  }
}
