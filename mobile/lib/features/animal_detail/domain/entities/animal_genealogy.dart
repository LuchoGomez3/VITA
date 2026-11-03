import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal_genealogy.freezed.dart';

/// Identidad de un animal dentro del árbol genealógico.
@freezed
sealed class GenealogyAnimal with _$GenealogyAnimal {
  /// Crea la identidad visible del animal.
  const factory GenealogyAnimal({
    /// UUID utilizado para abrir su ficha.
    required String id,

    /// Caravana visual.
    required String visualTag,

    /// Raza declarada.
    required String breed,

    /// Categoría actual; vacía si no se pudo resolver.
    required String categoryName,
  }) = _GenealogyAnimal;
}

/// Datos de parentesco necesarios para construir el árbol sin infraestructura.
@freezed
sealed class GenealogyAnimalRecord with _$GenealogyAnimalRecord {
  /// Crea un registro de parentesco local.
  const factory GenealogyAnimalRecord({
    /// Identidad del animal.
    required GenealogyAnimal animal,

    /// Fecha utilizada para ordenar las crías.
    required DateTime birthDate,

    /// UUID de la madre, si fue registrado.
    String? motherId,

    /// UUID del padre, si fue registrado.
    String? fatherId,
  }) = _GenealogyAnimalRecord;
}

/// Árbol de tres generaciones y crías; un pariente nulo no está disponible.
@freezed
sealed class AnimalGenealogy with _$AnimalGenealogy {
  /// Crea el árbol inmutable.
  const factory AnimalGenealogy({
    /// Padre.
    GenealogyAnimal? father,

    /// Madre.
    GenealogyAnimal? mother,

    /// Padre del padre.
    GenealogyAnimal? paternalGrandfather,

    /// Madre del padre.
    GenealogyAnimal? paternalGrandmother,

    /// Padre de la madre.
    GenealogyAnimal? maternalGrandfather,

    /// Madre de la madre.
    GenealogyAnimal? maternalGrandmother,

    /// Animales que tienen a este como madre o padre.
    @Default([]) List<GenealogyAnimal> offspring,
  }) = _AnimalGenealogy;
}
