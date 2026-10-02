import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';

/// Expone los animales locales necesarios para armar una venta.
abstract class LivestockSaleAnimalRepository {
  /// Busca una caravana en todo el inventario disponible en el dispositivo.
  ///
  /// El establecimiento se valida luego en dominio para poder diferenciar un
  /// animal inexistente de uno que pertenece a otro establecimiento.
  Future<Result<LivestockSaleAnimal?>> findLocalByRfidTagNumber(
    String rfidTagNumber,
  );
}
