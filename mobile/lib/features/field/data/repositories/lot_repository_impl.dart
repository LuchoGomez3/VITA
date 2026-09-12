import 'dart:io';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/data/mappers/lot_brick_mapper.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

/// Implementa lotes utilizando SQLite como única fuente de la Fase 2.
class LotRepositoryImpl implements LotRepository {
  /// Crea el repositorio con un store inyectable.
  const LotRepositoryImpl({required LotBrickStore store}) : _store = store;

  final LotBrickStore _store;
  static final Logger _logger = Logger('LotRepository');

  @override
  Future<Result<Lot>> saveLot(Lot lot) async {
    try {
      final saved = await _store.upsertLocalLot(LotBrickMapper.toBrick(lot));
      return Result.success(LotBrickMapper.fromBrick(saved));
    } on DatabaseException catch (error, stackTrace) {
      return _failure('No se pudo guardar el lote en el dispositivo.', error, stackTrace);
    } on OfflineFirstException catch (error, stackTrace) {
      return _failure('No se pudo guardar el lote en el dispositivo.', error, stackTrace);
    } on FileSystemException catch (error, stackTrace) {
      return _failure('No se pudo guardar el lote en el dispositivo.', error, stackTrace);
    } on FormatException catch (error, stackTrace) {
      return _failure('La geometría local del lote no es válida.', error, stackTrace);
    }
  }

  @override
  Future<Result<List<Lot>>> getLots(String establishmentId) async {
    try {
      final stored = await _store.getLocalLots(establishmentId);
      return Result.success(stored.map(LotBrickMapper.fromBrick).toList());
    } on Object catch (error, stackTrace) {
      return _failure('No se pudieron leer los lotes guardados.', error, stackTrace);
    }
  }

  @override
  Future<Result<Lot>> getLot(String lotId) async {
    try {
      final stored = await _store.getLocalLot(lotId);
      if (stored == null) {
        return const Result.failure(
          DomainException(
            message: 'El lote no está disponible en este dispositivo.',
            code: DomainErrorCode.notFound,
          ),
        );
      }
      return Result.success(LotBrickMapper.fromBrick(stored));
    } on Object catch (error, stackTrace) {
      return _failure('No se pudo leer el lote guardado.', error, stackTrace);
    }
  }

  Result<T> _failure<T>(String message, Object error, StackTrace stackTrace) {
    _logger.severe(message, error, stackTrace);
    return Result.failure(
      DomainException(message: message, code: DomainErrorCode.offline),
    );
  }
}
