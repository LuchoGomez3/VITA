import 'dart:io';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/stores/livestock_sale_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/mappers/livestock_sale_brick_mapper.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_repository.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

/// Implementa el alta de ventas contra el store local transaccional.
class LivestockSaleRepositoryImpl implements LivestockSaleRepository {
  /// Crea el repositorio con un store inyectable.
  const LivestockSaleRepositoryImpl({
    required LivestockSaleBrickStore saleStore,
  }) : _saleStore = saleStore;

  final LivestockSaleBrickStore _saleStore;
  static final Logger _logger = Logger('LivestockSaleRepository');

  @override
  Future<Result<LivestockSale>> createSale(LivestockSale sale) async {
    try {
      // El store confirma primero en SQLite y devuelve de inmediato; el envio
      // remoto queda en la cola offline y no bloquea la respuesta a UI.
      final saved = await _saleStore.saveSale(
        LivestockSaleBrickMapper.toBrick(sale),
      );
      return Result.success(LivestockSaleBrickMapper.fromBrick(saved));
    } on LivestockSaleLocalException catch (error) {
      // Los errores de integridad del store se traducen a conceptos de dominio
      // sin filtrar detalles de Brick hacia las capas superiores.
      final reason = switch (error.code) {
        LivestockSaleLocalErrorCode.invalidAnimalIds => LivestockSaleError.invalidAnimals,
        LivestockSaleLocalErrorCode.animalNotFound => LivestockSaleError.animalNotFound,
        LivestockSaleLocalErrorCode.differentEstablishment => LivestockSaleError.differentEstablishment,
        LivestockSaleLocalErrorCode.animalNotActive => LivestockSaleError.animalNotActive,
      };
      return Result.failure(
        DomainException(
          message: reason.name,
          code: reason == LivestockSaleError.animalNotFound ? DomainErrorCode.notFound : DomainErrorCode.conflict,
          reason: reason,
        ),
      );
    } on FormatException catch (error, stackTrace) {
      return _failure(LivestockSaleError.invalidStoredData, error, stackTrace);
    } on DatabaseException catch (error, stackTrace) {
      return _failure(LivestockSaleError.localSave, error, stackTrace);
    } on OfflineFirstException catch (error, stackTrace) {
      return _failure(LivestockSaleError.localSave, error, stackTrace);
    } on RestException catch (error, stackTrace) {
      return _failure(LivestockSaleError.localSave, error, stackTrace);
    } on FileSystemException catch (error, stackTrace) {
      return _failure(LivestockSaleError.localSave, error, stackTrace);
    }
  }

  Result<T> _failure<T>(
    LivestockSaleError reason,
    Exception error,
    StackTrace stackTrace,
  ) {
    // Las fallas tecnicas se registran con stack trace, mientras UI recibe un
    // error estable que puede explicar sin exponer detalles internos.
    _logger.severe('Expected livestock sale persistence failure: ${reason.name}', error, stackTrace);
    return Result.failure(
      DomainException(
        message: reason.name,
        code: DomainErrorCode.offline,
        reason: reason,
      ),
    );
  }
}
