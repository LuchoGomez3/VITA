import 'package:frontend_mayoral/brick/stores/livestock_sale_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/mappers/livestock_sale_brick_mapper.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';
import 'package:logging/logging.dart';

/// Adapta el historial SQLite al dominio; los cobros de la demo son locales.
class LivestockSaleHistoryRepositoryImpl implements LivestockSaleHistoryRepository {
  /// Recibe el store del historial para permitir pruebas sin infraestructura.
  const LivestockSaleHistoryRepositoryImpl(this._store);

  final LivestockSaleHistoryBrickStore _store;
  static final _logger = Logger('LivestockSaleHistoryRepository');

  @override
  Future<Result<List<LivestockSale>>> getSales(String establishmentId) async {
    try {
      final sales = await _store.getSales(establishmentId);
      return Result.success(sales.map(LivestockSaleBrickMapper.fromBrick).toList());
    } on Exception catch (error, stack) {
      return _failure(error, stack);
    }
  }

  @override
  Future<Result<LivestockSale>> collectUnpaidSale(LivestockSale sale) async {
    try {
      final saved = await _store.collectUnpaidSale(LivestockSaleBrickMapper.toBrick(sale));
      return Result.success(LivestockSaleBrickMapper.fromBrick(saved));
    } on LivestockSaleCollectionException {
      return const Result.failure(DomainException(message: 'Sale collection conflict', code: DomainErrorCode.conflict));
    } on Exception catch (error, stack) {
      return _failure(error, stack);
    }
  }

  Result<T> _failure<T>(Exception error, StackTrace stack) {
    _logger.severe('No se pudo acceder al historial local de ventas.', error, stack);
    return const Result.failure(
      DomainException(message: 'Sale history persistence failure', code: DomainErrorCode.offline),
    );
  }
}
