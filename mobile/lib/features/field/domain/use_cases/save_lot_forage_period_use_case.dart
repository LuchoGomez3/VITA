import 'package:frontend_mayoral/core/catalogs/forage_resource_catalog.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_forage_period_repository.dart';

/// Registra, corrige o borra un período del historial de recursos.
///
/// Valida en el celular lo mismo que backend, para no dejar en la cola algo
/// que el servidor va a rechazar.
class SaveLotForagePeriodUseCase {
  /// Crea el caso de uso con generador de UUID y reloj inyectables.
  SaveLotForagePeriodUseCase({
    required LotForagePeriodRepository repository,
    required String Function() createId,
    DateTime Function()? now,
  }) : _repository = repository,
       _createId = createId,
       _now = now ?? DateTime.now;

  final LotForagePeriodRepository _repository;
  final String Function() _createId;
  final DateTime Function() _now;

  /// Guarda el período. Con [existing] corrige ese período en vez de crear uno.
  Future<Result<LotForagePeriod>> call({
    required String establishmentId,
    required String lotId,
    required String resourceCode,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
    LotForagePeriod? existing,
  }) async {
    final start = _day(startDate);
    final end = endDate == null ? null : _day(endDate);
    final detail = description?.trim();
    final normalizedDescription = detail == null || detail.isEmpty ? null : detail;

    if (start.isAfter(_day(_now()))) {
      return _invalid('La fecha de inicio no puede ser futura.');
    }
    if (end != null && end.isBefore(start)) {
      return _invalid('La fecha de fin no puede ser anterior a la de inicio.');
    }
    if (resourceCode == ForageResourceCatalog.otherCode && normalizedDescription == null) {
      return _invalid('Describí el recurso cuando elegís "Otro".');
    }

    final periodsResult = await _repository.getPeriods(establishmentId: establishmentId, lotId: lotId);
    if (periodsResult case Failure<List<LotForagePeriod>>(:final error)) {
      return Result.failure(error);
    }
    final periods = (periodsResult as Success<List<LotForagePeriod>>).data;
    if (periods.any((period) => period.id != existing?.id && period.startDate == start)) {
      return const Result.failure(
        DomainException(
          message: 'El potrero ya tiene un recurso cargado desde esa fecha.',
          code: DomainErrorCode.conflict,
        ),
      );
    }

    final timestamp = _now().toUtc();
    final period = existing == null
        ? LotForagePeriod(
            id: _createId(),
            establishmentId: establishmentId,
            lotId: lotId,
            resourceCode: resourceCode,
            description: normalizedDescription,
            startDate: start,
            endDate: end,
            createdAt: timestamp,
            updatedAt: timestamp,
          )
        : existing.copyWith(
            resourceCode: resourceCode,
            description: normalizedDescription,
            startDate: start,
            endDate: end,
            updatedAt: timestamp,
          );
    return _repository.savePeriod(period);
  }

  /// Borrado lógico: el tombstone también se sincroniza.
  Future<Result<LotForagePeriod>> delete(LotForagePeriod period) {
    final timestamp = _now().toUtc();
    return _repository.savePeriod(period.copyWith(deletedAt: timestamp, updatedAt: timestamp));
  }

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

  static Result<LotForagePeriod> _invalid(String message) =>
      Result.failure(DomainException(message: message, code: DomainErrorCode.validation));
}
