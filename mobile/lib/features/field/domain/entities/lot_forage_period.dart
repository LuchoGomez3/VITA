import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';

part 'lot_forage_period.freezed.dart';

/// Desde [startDate], el lote tuvo el recurso [resourceCode].
///
/// No hace falta cerrar el período anterior: termina el día antes del
/// siguiente. [endDate] solo se usa para un corte (el potrero quedó sin
/// recurso). Las fechas son días calendario locales, sin hora.
@freezed
sealed class LotForagePeriod with _$LotForagePeriod {
  /// Crea un período del historial de recursos.
  const factory LotForagePeriod({
    required String id,
    required String establishmentId,
    required String lotId,
    required String resourceCode,
    required DateTime startDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    DateTime? endDate,
    @Default(LotSyncStatus.pending) LotSyncStatus syncStatus,
    String? syncErrorCode,
    DateTime? deletedAt,
  }) = _LotForagePeriod;
}

/// Reglas de lectura del historial de recursos de un lote.
abstract final class LotForageTimeline {
  /// Recurso vigente: el período más reciente, si no tiene un corte.
  static LotForagePeriod? current(Iterable<LotForagePeriod> periods) {
    LotForagePeriod? latest;
    for (final period in periods) {
      if (latest == null || period.startDate.isAfter(latest.startDate)) {
        latest = period;
      }
    }
    return latest?.endDate == null ? latest : null;
  }

  /// Último día efectivo de [period] dentro de [periods]: su corte o el día
  /// anterior al siguiente período, lo que llegue primero. Null si sigue vigente.
  static DateTime? effectiveEnd(LotForagePeriod period, Iterable<LotForagePeriod> periods) {
    DateTime? nextStart;
    for (final other in periods) {
      if (other.startDate.isAfter(period.startDate) && (nextStart == null || other.startDate.isBefore(nextStart))) {
        nextStart = other.startDate;
      }
    }
    final dayBeforeNext = nextStart == null ? null : DateTime(nextStart.year, nextStart.month, nextStart.day - 1);
    final end = period.endDate;
    if (end == null) return dayBeforeNext;
    if (dayBeforeNext == null) return end;
    return end.isBefore(dayBeforeNext) ? end : dayBeforeNext;
  }

  /// Historial del más reciente al más antiguo.
  static List<LotForagePeriod> newestFirst(Iterable<LotForagePeriod> periods) =>
      periods.toList()..sort((a, b) => b.startDate.compareTo(a.startDate));
}
