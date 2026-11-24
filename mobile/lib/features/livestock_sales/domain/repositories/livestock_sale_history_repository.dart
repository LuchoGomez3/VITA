import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';

/// Contrato de lectura del historial local de ventas.
abstract class LivestockSaleHistoryRepository {
  /// Cambios locales de ventas que requieren actualizar consultas activas.
  Stream<void> get changes => const Stream<void>.empty();

  /// Obtiene las ventas vigentes del establecimiento indicado.
  Future<Result<List<LivestockSale>>> getSales(String establishmentId);

  /// Obtiene una venta local sin permitir cruzar establecimientos.
  Future<Result<LivestockSale>> getSale({
    required String establishmentId,
    required String saleId,
  });
}
