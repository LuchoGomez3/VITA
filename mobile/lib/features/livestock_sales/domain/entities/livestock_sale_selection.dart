import 'package:freezed_annotation/freezed_annotation.dart';

part 'livestock_sale_selection.freezed.dart';

/// Estado productivo conocido por el flujo de seleccion de una venta.
enum LivestockSaleAnimalStatus {
  /// El animal integra el stock disponible.
  active,

  /// El animal ya fue vendido.
  sold,

  /// El animal fue registrado como muerto.
  dead,

  /// El animal fue dado de baja por otro motivo.
  removed,

  /// El dispositivo no puede asegurar el estado productivo.
  unknown,
}

/// Datos necesarios para identificar un animal dentro de una venta.
@freezed
sealed class LivestockSaleAnimal with _$LivestockSaleAnimal {
  /// Crea una representacion liviana obtenida desde el inventario local.
  const factory LivestockSaleAnimal({
    required String id,
    required String establishmentId,
    required String rfidTagNumber,
    required String visualTag,
    required String categoryName,
    required String lotName,
    required LivestockSaleAnimalStatus status,
  }) = _LivestockSaleAnimal;
}

/// Animales elegidos para una venta, conservados en orden de seleccion.
@freezed
sealed class LivestockSaleSelection with _$LivestockSaleSelection {
  /// Crea una seleccion vacia o con animales previamente elegidos.
  const factory LivestockSaleSelection({
    @Default(<LivestockSaleAnimal>[]) List<LivestockSaleAnimal> animals,
  }) = _LivestockSaleSelection;
}
