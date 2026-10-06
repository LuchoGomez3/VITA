import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';

/// Contrato para consultar ventas y completar su primer cobro local.
abstract class LivestockSaleHistoryRepository {
  /// Obtiene el historial aislado por establecimiento.
  Future<Result<List<LivestockSale>>> getSales(String establishmentId);

  /// Guarda el cobro sin volver a descontar animales del inventario.
  Future<Result<LivestockSale>> collectUnpaidSale(LivestockSale sale);
}
