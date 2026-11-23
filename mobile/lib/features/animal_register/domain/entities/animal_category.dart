import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

part 'animal_category.freezed.dart';

/// Sexo que admite una categoría productiva.
enum AnimalCategorySex {
  /// Admite hembras.
  female,

  /// Admite machos.
  male,

  /// Admite tanto hembras como machos.
  both;

  /// Indica si la categoría se puede usar con el sexo elegido.
  bool allows(AnimalSex sex) => switch (this) {
    female => sex == AnimalSex.female,
    male => sex == AnimalSex.male,
    both => true,
  };
}

/// Categoria productiva seleccionable durante el alta de un animal.
@freezed
sealed class AnimalCategory with _$AnimalCategory {
  /// Crea una categoria con su identidad estable y nombre visible.
  const factory AnimalCategory({
    /// UUID administrado por backend y referenciado por el animal.
    required String id,

    /// Nombre presentado al productor.
    required String name,

    /// Regla que limita su selección según el sexo del animal.
    required AnimalCategorySex allowedSex,
  }) = _AnimalCategory;
}
