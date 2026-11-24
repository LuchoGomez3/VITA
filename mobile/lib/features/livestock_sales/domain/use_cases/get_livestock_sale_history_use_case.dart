import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';

/// Consulta ventas guardadas sin exponer SQLite a presentacion.
class GetLivestockSaleHistoryUseCase {
  /// Crea el caso de uso con su contrato de lectura.
  const GetLivestockSaleHistoryUseCase(this._repository);

  final LivestockSaleHistoryRepository _repository;

  /// Expone cambios locales sin filtrar detalles de persistencia.
  Stream<void> get changes => _repository.changes;

  /// Obtiene el historial aislado por establecimiento.
  Future<Result<List<LivestockSale>>> call(String establishmentId) {
    return _repository.getSales(establishmentId);
  }
}
