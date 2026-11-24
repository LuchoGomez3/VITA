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

    /// Estado productivo elegido. Nulo incluye todos los estados.
    @Default(AnimalProductiveStatus.active) AnimalProductiveStatus? productiveStatus,

    /// Identificador del potrero elegido.
    String? lotId,

    /// Potreros guardados de cada establecimiento, incluso los vacíos.
    @Default(<String, Map<String, String>>{}) Map<String, Map<String, String>> lotsByEstablishment,

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

  /// Lotes disponibles en el alcance de la lista.
  Map<String, String> get lotOptions {
    final options = {
      for (final animal in allAnimals)
        if (animal.lotId.isNotEmpty && animal.lotName.isNotEmpty) animal.lotId: animal.lotName,
      for (final entry in lotsByEstablishment.entries)
        if (establishmentId == null || entry.key == establishmentId) ...entry.value,
    };
    final sorted = options.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    return Map.fromEntries(sorted);
  }

  /// Base de los filtros rápidos. Conserva el estado y el lote seleccionados.
  List<AnimalListEntry> get statusAndLotAnimals => [
    for (final animal in allAnimals)
      if ((productiveStatus == null || animal.productiveStatus == productiveStatus) &&
          (lotId == null || animal.lotId == lotId))
        animal,
  ];

  /// Animales que cumplen la búsqueda y la categoría elegida.
  List<AnimalListEntry> get visibleAnimals {
    final normalizedQuery = query.trim().toLowerCase().replaceAll(' ', '');
    return [
      for (final animal in statusAndLotAnimals)
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
