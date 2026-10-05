import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_change.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';

part 'animal_detail_state.freezed.dart';

/// Separa la carga de la ficha del guardado para no ocultarla durante una edición.
@freezed
sealed class AnimalDetailState with _$AnimalDetailState {
  /// Mantiene además la versión de la última baja para un deshacer seguro.
  const factory AnimalDetailState({
    @Default(ResultState<AnimalDetail>.initial()) ResultState<AnimalDetail> detail,
    @Default(ResultState<AnimalDetail>.initial()) ResultState<AnimalDetail> saving,
    AnimalDetailChange? lastChange,
    AnimalStatus? undoStatus,
    DateTime? deathVersion,
  }) = _AnimalDetailState;
}
