import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';

part 'animal_detail_state.freezed.dart';

/// Estado independiente de la ficha y su foto local opcional.
@freezed
sealed class AnimalDetailState with _$AnimalDetailState {
  /// Crea el estado de presentacion de detalle.
  const factory AnimalDetailState({
    required ResultState<AnimalDetail> detail,
    required ResultState<AnimalPhoto?> photo,
  }) = _AnimalDetailState;

  /// Estado inicial antes de comenzar las lecturas.
  static const initial = AnimalDetailState(
    detail: ResultState<AnimalDetail>.initial(),
    photo: ResultState<AnimalPhoto?>.initial(),
  );
}
