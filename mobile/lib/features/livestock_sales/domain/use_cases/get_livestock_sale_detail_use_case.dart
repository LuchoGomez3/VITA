import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';

/// Consulta una venta local dentro del establecimiento autorizado.
class GetLivestockSaleDetailUseCase {
  /// Crea el caso de uso sobre el contrato del historial.
  const GetLivestockSaleDetailUseCase(this._repository);

  final LivestockSaleHistoryRepository _repository;

  /// Expone cambios de la venta mientras el detalle permanece abierto.
  Stream<void> get changes => _repository.changes;

  /// Obtiene el detalle sin exponer Brick a presentacion.
  Future<Result<LivestockSale>> call({
    required String establishmentId,
    required String saleId,
  }) {
    return _repository.getSale(
      establishmentId: establishmentId,
      saleId: saleId,
    );
  }
}
