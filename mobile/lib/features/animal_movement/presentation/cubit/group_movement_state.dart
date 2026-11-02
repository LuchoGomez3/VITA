import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_tag_kind.dart';

part 'group_movement_state.freezed.dart';

/// Selección editable y resultados independientes de cada operación asíncrona.
@freezed
sealed class GroupMovementState with _$GroupMovementState {
  /// Inicia sin datos, sin lectura de caravana ni guardado en curso.
  const factory GroupMovementState({
    @Default(ResultState<GroupMovementPreparation>.initial()) ResultState<GroupMovementPreparation> preparation,
    @Default(ResultState<MovementAnimal>.initial()) ResultState<MovementAnimal> tagResolution,
    @Default(ResultState<GroupMovementSummary>.initial()) ResultState<GroupMovementSummary> submission,
    @Default([]) List<MovementAnimal> animals,
    @Default(MovementTagKind.rfid) MovementTagKind tagKind,

    /// Cambios durables acumulados, incluso si un grupo posterior falla.
    @Default(GroupMovementSummary(movedCount: 0, alreadyThereCount: 0)) GroupMovementSummary savedSummary,
    String? destinationId,
    DateTime? occurredAt,
  }) = _GroupMovementState;

  const GroupMovementState._();

  /// Establecimiento del animal inicial, disponible después de preparar.
  String get establishmentId => switch (preparation) {
    Data<GroupMovementPreparation>(:final data) => data.animal.establishmentId,
    _ => '',
  };

  /// Opciones obtenidas al preparar el traslado.
  List<MovementDestination> get destinations => switch (preparation) {
    Data<GroupMovementPreparation>(:final data) => data.destinations,
    _ => const [],
  };

  /// Animales que cambiarían de ubicación según el destino elegido.
  int get movableCount => animals.where((animal) => animal.lotId != destinationId).length;
}
