import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';

part 'home_dashboard_source.freezed.dart';

/// Datos de dominio necesarios para calcular el tablero sin conocer Brick.
@freezed
sealed class HomeDashboardSource with _$HomeDashboardSource {
  /// Crea una fotografia consistente de los datos locales disponibles.
  const factory HomeDashboardSource({
    required List<HomeDashboardAnimal> animals,
    required List<HomeDashboardWeighing> weighings,
    required Map<String, String> categoryNamesById,
    required int operatingExpensesCents,
  }) = _HomeDashboardSource;
}

/// Proyeccion de un animal usada por las reglas productivas de Inicio.
@freezed
sealed class HomeDashboardAnimal with _$HomeDashboardAnimal {
  /// Crea la proyeccion independiente de SQLite y REST.
  const factory HomeDashboardAnimal({
    required String id,
    required AnimalProductiveStatus productiveStatus,
    required DateTime createdAt,
    required DateTime? deletedAt,
    required DateTime? productiveStatusChangedAt,
    required String categoryId,
    required String categoryName,
    required String lotName,
    required double? initialWeightKg,
    required DateTime initialWeighingDate,
  }) = _HomeDashboardAnimal;
}

/// Pesaje minimo requerido para calcular peso vigente y GPD.
@freezed
sealed class HomeDashboardWeighing with _$HomeDashboardWeighing {
  /// Crea un pesaje de la fotografia local.
  const factory HomeDashboardWeighing({
    required String animalId,
    required double weightKg,
    required DateTime date,
  }) = _HomeDashboardWeighing;
}
