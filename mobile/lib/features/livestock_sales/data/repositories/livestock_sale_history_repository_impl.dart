import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:frontend_mayoral/brick/stores/livestock_sale_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/mappers/livestock_sale_brick_mapper.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

/// Adapta las ventas vigentes de SQLite al dominio de visualizacion.
class LivestockSaleHistoryRepositoryImpl implements LivestockSaleHistoryRepository {
  /// Crea el repositorio con un store inyectable.
  const LivestockSaleHistoryRepositoryImpl({
    required LivestockSaleBrickStore saleStore,
  }) : _saleStore = saleStore;

  final LivestockSaleBrickStore _saleStore;
  static final _logger = Logger('LivestockSaleHistoryRepository');

  @override
  Stream<void> get changes => _saleStore.changes;

  @override
  Future<Result<List<LivestockSale>>> getSales(
    String establishmentId,
  ) async {
    try {
      final stored = await _saleStore.getLocalSales(establishmentId);
      return Result.success(
        stored.map(LivestockSaleBrickMapper.fromBrick).toList(),
      );
    } on FormatException catch (error, stackTrace) {
      return _failure(error, stackTrace);
    } on DatabaseException catch (error, stackTrace) {
      return _failure(error, stackTrace);
    } on OfflineFirstException catch (error, stackTrace) {
      return _failure(error, stackTrace);
    }
  }

  @override
  Future<Result<LivestockSale>> getSale({
    required String establishmentId,
    required String saleId,
  }) async {
    final result = await getSales(establishmentId);
    return result.when(
      success: (sales) => _findSale(sales, saleId),
      failure: Result.failure,
    );
  }

  Result<LivestockSale> _findSale(
    Iterable<LivestockSale> sales,
    String saleId,
  ) {
    for (final sale in sales) {
      if (sale.id == saleId) return Result.success(sale);
    }
    return const Result.failure(
      DomainException(
        message: 'Livestock sale not found in local storage',
        code: DomainErrorCode.notFound,
      ),
    );
  }

  Result<T> _failure<T>(Exception error, StackTrace stackTrace) {
    _logger.severe(
      'No se pudo leer el historial local de ventas.',
      error,
      stackTrace,
    );
    return const Result.failure(
      DomainException(
        message: 'Sale history persistence failure',
        code: DomainErrorCode.offline,
      ),
    );
  }
}
