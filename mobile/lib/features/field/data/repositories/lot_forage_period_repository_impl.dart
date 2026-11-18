import 'package:frontend_mayoral/brick/models/lot_forage_period.model.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_forage_period_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/data/mappers/lot_forage_period_brick_mapper.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_forage_period_repository.dart';
import 'package:logging/logging.dart';

/// Historial de recursos guardado en SQLite y sincronizado con Brick.
class LotForagePeriodRepositoryImpl implements LotForagePeriodRepository {
  /// Crea el repositorio con sus stores inyectables.
  const LotForagePeriodRepositoryImpl({
    required LotForagePeriodBrickStore periodStore,
    required LotBrickStore lotStore,
    Stream<Type> localChanges = const Stream.empty(),
  }) : _periodStore = periodStore,
       _lotStore = lotStore,
       _localChanges = localChanges;

  final LotForagePeriodBrickStore _periodStore;
  final LotBrickStore _lotStore;
  final Stream<Type> _localChanges;

  @override
  Stream<void> get changes => _localChanges.where((type) => type == BrickLotForagePeriodModel).map((_) {});
  static final _logger = Logger('LotForagePeriodRepository');

  @override
  Future<Result<List<LotForagePeriod>>> getPeriods({
    required String establishmentId,
    required String lotId,
  }) async {
    try {
      final stored = await _periodStore.getLocalPeriods(establishmentId, lotId: lotId);
      return Result.success(stored.map(LotForagePeriodBrickMapper.fromBrick).toList());
    } on Object catch (error, stackTrace) {
      return _failure('No se pudo leer el historial de recursos del potrero.', error, stackTrace);
    }
  }

  @override
  Future<Result<LotForagePeriod>> savePeriod(LotForagePeriod period) async {
    try {
      final saved = await _periodStore.save(LotForagePeriodBrickMapper.toBrick(period));
      final periods = await _periodStore.getLocalPeriods(period.establishmentId, lotId: period.lotId);
      final current = LotForageTimeline.current(periods.map(LotForagePeriodBrickMapper.fromBrick));
      await _lotStore.setLocalForageResource(period.lotId, current?.resourceCode);
      return Result.success(LotForagePeriodBrickMapper.fromBrick(saved));
    } on Object catch (error, stackTrace) {
      return _failure('No se pudo guardar el recurso del potrero en el dispositivo.', error, stackTrace);
    }
  }

  Result<T> _failure<T>(String message, Object error, StackTrace stackTrace) {
    _logger.severe(message, error, stackTrace);
    return Result.failure(DomainException(message: message, code: DomainErrorCode.offline));
  }
}
