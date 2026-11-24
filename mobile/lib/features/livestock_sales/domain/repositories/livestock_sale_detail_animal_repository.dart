import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';

/// Expone los animales asociados a una venta desde el inventario local.
abstract class LivestockSaleDetailAnimalRepository {
  /// Lee los UUID dentro del establecimiento activo y conserva su orden.
  Future<Result<List<LivestockSaleAnimal>>> findLocalByIds(
    List<String> animalIds,
  );
}
