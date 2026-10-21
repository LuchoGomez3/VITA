import 'package:meta/meta.dart';

/// Un animal del árbol genealógico, con lo necesario para dibujar su nodo.
@immutable
class GenealogyAnimal {
  /// Crea el nodo.
  const GenealogyAnimal({
    required this.id,
    required this.visualTag,
    required this.breed,
    required this.categoryName,
  });

  /// ID del animal (abre su ficha).
  final String id;

  /// Caravana visual.
  final String visualTag;

  /// Raza declarada.
  final String breed;

  /// Categoría actual; vacía si no se pudo resolver.
  final String categoryName;

  @override
  bool operator ==(Object other) =>
      other is GenealogyAnimal &&
      other.id == id &&
      other.visualTag == visualTag &&
      other.breed == breed &&
      other.categoryName == categoryName;

  @override
  int get hashCode => Object.hash(id, visualTag, breed, categoryName);
}

/// Árbol de tres generaciones de un animal (él, padres y abuelos) y sus crías.
///
/// Un progenitor en `null` es un dato que falta: no se cargó en el alta, es de
/// otro establecimiento o se dio de baja.
@immutable
class AnimalGenealogy {
  /// Crea el árbol.
  const AnimalGenealogy({
    this.father,
    this.mother,
    this.paternalGrandfather,
    this.paternalGrandmother,
    this.maternalGrandfather,
    this.maternalGrandmother,
    this.offspring = const [],
  });

  /// Padre.
  final GenealogyAnimal? father;

  /// Madre.
  final GenealogyAnimal? mother;

  /// Padre del padre.
  final GenealogyAnimal? paternalGrandfather;

  /// Madre del padre.
  final GenealogyAnimal? paternalGrandmother;

  /// Padre de la madre.
  final GenealogyAnimal? maternalGrandfather;

  /// Madre de la madre.
  final GenealogyAnimal? maternalGrandmother;

  /// Animales que tienen a este como madre o padre.
  final List<GenealogyAnimal> offspring;
}
