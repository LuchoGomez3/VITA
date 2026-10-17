import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal_category.freezed.dart';

/// Categoria productiva seleccionable durante el alta de un animal.
@freezed
sealed class AnimalCategory with _$AnimalCategory {
  /// Crea una categoria con su identidad estable y nombre visible.
  const factory AnimalCategory({
    /// UUID administrado por backend y referenciado por el animal.
    required String id,

    /// Nombre presentado al productor.
    required String name,
  }) = _AnimalCategory;
}
