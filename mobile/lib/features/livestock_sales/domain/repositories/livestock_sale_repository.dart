import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';

/// Persiste ventas completas sin exponer Brick a dominio o presentacion.
abstract class LivestockSaleRepository {
  /// Guarda la operacion local y devuelve inmediatamente su estado offline.
  Future<Result<LivestockSale>> createSale(LivestockSale sale);
}
