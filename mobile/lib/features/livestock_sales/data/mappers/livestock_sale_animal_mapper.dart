import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';

/// Traduce el animal persistido por Brick al modelo usado por ventas.
abstract final class LivestockSaleAnimalMapper {
  /// Crea el animal seleccionable conservando su estado productivo local.
  static LivestockSaleAnimal fromBrick(BrickAnimalModel animal) {
    return LivestockSaleAnimal(
      id: animal.localId,
      establishmentId: animal.establishmentId,
      rfidTagNumber: animal.rfidTagNumber,
      visualTag: animal.visualTag,
      categoryName: animal.categoryName,
      lotName: animal.lotName,
      status: _statusFromBrick(animal.status),
    );
  }

  static LivestockSaleAnimalStatus _statusFromBrick(
    String status,
  ) {
    return switch (status) {
      'activo' => LivestockSaleAnimalStatus.active,
      'vendido' => LivestockSaleAnimalStatus.sold,
      'muerto' => LivestockSaleAnimalStatus.dead,
      'baja' => LivestockSaleAnimalStatus.removed,
      _ => LivestockSaleAnimalStatus.unknown,
    };
  }
}
