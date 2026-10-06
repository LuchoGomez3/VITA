import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';

/// Consulta ventas sin depender de conectividad ni exponer SQLite a la UI.
class GetLivestockSaleHistoryUseCase {
  /// Recibe el contrato de lectura del historial.
  const GetLivestockSaleHistoryUseCase(this._repository);

  final LivestockSaleHistoryRepository _repository;

  /// Obtiene únicamente las operaciones del establecimiento activo.
  Future<Result<List<LivestockSale>>> call(String establishmentId) => _repository.getSales(establishmentId);
}

/// Completa el primer cobro; nunca modifica el precio pactado de la venta.
class CollectUnpaidLivestockSaleUseCase {
  /// Permite inyectar reloj e identidad para verificar auditoría en pruebas.
  CollectUnpaidLivestockSaleUseCase(this._repository, {DateTime Function()? now, String Function()? createId})
    : _now = now ?? DateTime.now,
      _createId = createId ?? generateUuidV4;

  final LivestockSaleHistoryRepository _repository;
  final DateTime Function() _now;
  final String Function() _createId;

  /// Valida un cobro positivo que no supere el total y lo guarda localmente.
  Future<Result<LivestockSale>> call({
    required LivestockSale sale,
    required int amountCents,
    required LivestockSalePaymentMethod method,
  }) {
    if (sale.initialPayment != null || sale.paymentCondition != LivestockSalePaymentCondition.pending) {
      return Future.value(
        const Result.failure(DomainException(message: 'Sale already collected', code: DomainErrorCode.conflict)),
      );
    }
    if (amountCents <= 0 || amountCents > sale.totalAmountCents) {
      return Future.value(
        const Result.failure(DomainException(message: 'Invalid collected amount', code: DomainErrorCode.validation)),
      );
    }
    final now = _now();
    // El pago tiene su propia identidad y fecha. Un importe menor al total
    // conserva el saldo como parcial, sin confundir cobrado con precio de venta.
    return _repository.collectUnpaidSale(
      sale.copyWith(
        paymentCondition: amountCents == sale.totalAmountCents
            ? LivestockSalePaymentCondition.total
            : LivestockSalePaymentCondition.partial,
        initialPayment: LivestockSaleInitialPayment(
          id: _createId(),
          date: DateTime(now.year, now.month, now.day),
          amountCents: amountCents,
          method: method,
          createdAt: now.toUtc(),
          updatedAt: now.toUtc(),
        ),
        updatedAt: now.toUtc(),
      ),
    );
  }
}
