import 'package:freezed_annotation/freezed_annotation.dart';

part 'feeding_entities.freezed.dart';

/// Qué se le dio al animal además del pastoreo del potrero.
enum FeedingType {
  /// Agregado puntual o temporal (grano en sequía, sales).
  supplement('suplemento'),

  /// Régimen que define su alimentación (engorde, recría a corral).
  diet('dieta');

  const FeedingType(this.code);

  /// Código acordado con backend.
  final String code;

  /// Interpreta un código; los desconocidos se leen como suplemento.
  static FeedingType fromCode(String code) => values.firstWhere((t) => t.code == code, orElse: () => supplement);
}

/// A qué se refiere la cantidad de un registro.
enum FeedingQuantityBasis {
  /// Cada animal recibe esa cantidad por día.
  perAnimalDay('por_animal_dia'),

  /// Es lo que recibe todo el grupo por día.
  groupDay('grupo_dia');

  const FeedingQuantityBasis(this.code);

  /// Código acordado con backend.
  final String code;

  /// Interpreta un código; los desconocidos se leen por animal.
  static FeedingQuantityBasis fromCode(String code) =>
      values.firstWhere((b) => b.code == code, orElse: () => perAnimalDay);
}

/// Estado de sincronización visible en la ficha.
enum FeedingSyncStatus {
  /// Guardado en el celular, esperando señal.
  pending,

  /// Confirmado por el servidor.
  synchronized,

  /// Rechazado por el servidor.
  rejected,
}

/// Por qué un tramo de pastoreo se infirió en vez de salir de movimientos.
enum GrazingEstimateReason {
  /// El animal no tiene movimientos: se asume su potrero actual desde el alta.
  noMovements,

  /// Antes del primer movimiento: se asume el potrero de origen desde el alta.
  beforeFirstMovement,

  /// Dos movimientos no encadenan: sale de un potrero distinto al que llegó.
  brokenChain,

  /// El potrero se cambió desde la ficha, sin registrar un movimiento.
  lotEditedWithoutMovement,
}

/// Alimento del catálogo del establecimiento.
@freezed
sealed class Food with _$Food {
  /// Crea un alimento.
  const factory Food({
    required String id,
    required String name,
    required String categoryCode,
    required String unitCode,
    @Default(false) bool isGlobal,
  }) = _Food;
}

/// Animal que se puede incluir en un registro de alimentación.
@freezed
sealed class FeedingAnimal with _$FeedingAnimal {
  /// Crea el resumen del animal.
  const factory FeedingAnimal({
    required String id,
    required String establishmentId,
    required String visualTag,
    required String rfidTagNumber,
    required String breed,
    required String categoryName,
    required String lotId,
    required String lotName,
  }) = _FeedingAnimal;
}

/// Potrero que se puede elegir como lugar del suministro.
@freezed
sealed class FeedingLot with _$FeedingLot {
  /// Crea la opción.
  const factory FeedingLot({required String id, required String name}) = _FeedingLot;
}

/// Suplemento o dieta a registrar para uno o varios animales.
@freezed
sealed class FeedingRecord with _$FeedingRecord {
  /// Crea el registro. Las fechas son días calendario; [endDate] null = en curso.
  const factory FeedingRecord({
    required String id,
    required String establishmentId,
    required FeedingType type,
    required String foodId,
    required DateTime startDate,
    required String quantity,
    required String unitCode,
    required FeedingQuantityBasis basis,
    required List<String> animalIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? lotId,
    DateTime? endDate,
    String? reason,
  }) = _FeedingRecord;
}

/// Una entrada del historial de alimentación del animal.
@freezed
sealed class FeedingTimelineEntry with _$FeedingTimelineEntry {
  /// Tramo de pastoreo derivado de sus movimientos y del recurso del potrero.
  ///
  /// [resourceCode] null = el potrero no tenía recurso cargado en ese tramo.
  /// [estimateReason] no nulo = el tramo no sale de un movimiento registrado y
  /// se infirió; dice por qué. [to] null = sigue hoy.
  const factory FeedingTimelineEntry.grazing({
    required String lotId,
    required String lotName,
    required DateTime from,
    String? resourceCode,
    String? resourceDescription,
    DateTime? to,
    GrazingEstimateReason? estimateReason,
    @Default(false) bool pending,
  }) = GrazingEntry;

  /// Suplemento o dieta registrado a mano.
  const factory FeedingTimelineEntry.supplement({
    required String recordId,
    required FeedingType type,
    required String foodName,
    required String quantity,
    required String unitCode,
    required FeedingQuantityBasis basis,
    required DateTime from,
    required FeedingSyncStatus syncStatus,
    DateTime? to,
    String? lotName,
    String? reason,
    String? syncErrorCode,
  }) = SupplementEntry;

  const FeedingTimelineEntry._();

  /// El tramo de pastoreo se infirió (ver [GrazingEntry.estimateReason]).
  bool get estimated => switch (this) {
    GrazingEntry(:final estimateReason) => estimateReason != null,
    SupplementEntry() => false,
  };

  /// Primer día del tramo.
  DateTime get startDate => switch (this) {
    GrazingEntry(:final from) => from,
    SupplementEntry(:final from) => from,
  };
}

/// Lo que muestra la pestaña Alimentación.
@freezed
sealed class AnimalFeedingHistory with _$AnimalFeedingHistory {
  /// Crea el historial.
  const factory AnimalFeedingHistory({
    required List<FeedingTimelineEntry> entries,
    GrazingEntry? currentGrazing,
    @Default(<SupplementEntry>[]) List<SupplementEntry> ongoingSupplements,
    String? currentLotId,
    @Default(false) bool currentLotHasForage,
  }) = _AnimalFeedingHistory;
}
