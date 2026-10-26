part of 'animal_list_cubit.dart';

/// Estado de la lista de animales de Hacienda.
@freezed
sealed class AnimalListState with _$AnimalListState {
  /// Crea el estado de la lista.
  const factory AnimalListState({
    @Default(ResultState<List<AnimalListEntry>>.initial()) ResultState<List<AnimalListEntry>> animals,

    /// Texto buscado (caravana, RFID o raza).
    @Default('') String query,

    /// Categoría elegida en los chips, o `null` para "Todos".
    String? category,

    /// Establecimientos del usuario, para el selector de la cabecera.
    @Default(<EstablishmentMembership>[]) List<EstablishmentMembership> establishments,

    /// Establecimiento elegido, o `null` para ver todos.
    String? establishmentId,
  }) = _AnimalListState;

  const AnimalListState._();

  /// Animales del establecimiento elegido (o de todos), sin filtros de
  /// búsqueda ni categoría.
  List<AnimalListEntry> get allAnimals {
    final loaded = switch (animals) {
      Data<List<AnimalListEntry>>(:final data) => data,
      _ => const <AnimalListEntry>[],
    };
    final selected = establishmentId;
    if (selected == null) {
      return loaded;
    }
    return [
      for (final animal in loaded)
        if (animal.establishmentId == selected) animal,
    ];
  }

  /// Establecimiento elegido, o `null` si se ven todos.
  EstablishmentMembership? get selectedEstablishment {
    for (final establishment in establishments) {
      if (establishment.id == establishmentId) {
        return establishment;
      }
    }
    return null;
  }

  /// Categorías presentes en la hacienda, ordenadas alfabéticamente.
  List<String> get categories {
    final names = {
      for (final animal in allAnimals)
        if (animal.categoryName.isNotEmpty) animal.categoryName,
    }.toList()..sort();
    return names;
  }

  /// Animales que cumplen la búsqueda y la categoría elegida.
  List<AnimalListEntry> get visibleAnimals {
    final normalizedQuery = query.trim().toLowerCase().replaceAll(' ', '');
    return [
      for (final animal in allAnimals)
        if ((category == null || animal.categoryName == category) && _matches(animal, normalizedQuery)) animal,
    ];
  }

  static bool _matches(AnimalListEntry animal, String normalizedQuery) {
    if (normalizedQuery.isEmpty) {
      return true;
    }
    return animal.visualTag.toLowerCase().replaceAll(' ', '').contains(normalizedQuery) ||
        animal.rfidTagNumber.contains(normalizedQuery) ||
        animal.breed.toLowerCase().replaceAll(' ', '').contains(normalizedQuery);
  }
}
