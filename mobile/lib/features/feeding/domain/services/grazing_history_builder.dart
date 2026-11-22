import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';

/// Lo que se sabe del animal para reconstruir dónde estuvo.
class GrazingAnimalSnapshot {
  /// Crea la foto del animal.
  const GrazingAnimalSnapshot({
    required this.createdAt,
    required this.updatedAt,
    required this.currentLotId,
    this.exitedAt,
  });

  /// Alta del animal en la app.
  final DateTime createdAt;

  /// Última modificación (si el lote cambió sin un movimiento, fue acá).
  final DateTime updatedAt;

  /// Potrero actual; vacío si no tiene.
  final String currentLotId;

  /// Cuándo dejó el stock (venta, muerte); null si sigue.
  final DateTime? exitedAt;
}

/// Un movimiento que incluye al animal.
class GrazingMovement {
  /// Crea el movimiento.
  const GrazingMovement({
    required this.occurredAt,
    required this.createdAt,
    required this.destinationLotId,
    this.sourceLotId,
    this.pending = false,
  });

  /// Fecha efectiva del movimiento.
  final DateTime occurredAt;

  /// Desempata movimientos del mismo instante.
  final DateTime createdAt;

  /// Potrero de origen; null en la primera asignación.
  final String? sourceLotId;

  /// Potrero de destino.
  final String destinationLotId;

  /// Todavía no llegó al servidor.
  final bool pending;
}

/// Un período del historial de recursos de un potrero.
class GrazingForagePeriod {
  /// Crea el período.
  const GrazingForagePeriod({
    required this.lotId,
    required this.resourceCode,
    required this.startDate,
    this.description,
    this.endDate,
  });

  /// Potrero.
  final String lotId;

  /// Código del recurso.
  final String resourceCode;

  /// Detalle libre.
  final String? description;

  /// Primer día.
  final DateTime startDate;

  /// Corte explícito.
  final DateTime? endDate;
}

/// Reconstruye qué pastoreó un animal, sin conexión.
///
/// Cruza sus movimientos entre potreros con el historial de recursos de cada
/// potrero. El historial de movimientos tiene huecos conocidos (editar el lote
/// del animal o darlo de alta no genera un movimiento): esos tramos se infieren
/// y se marcan como estimados (adr-0015).
abstract final class GrazingHistoryBuilder {
  /// Tramos de pastoreo del más reciente al más antiguo.
  static List<GrazingEntry> build({
    required GrazingAnimalSnapshot animal,
    required List<GrazingMovement> movements,
    required List<GrazingForagePeriod> periods,
    required Map<String, String> lotNames,
    required DateTime today,
  }) {
    final stays = _stays(animal, movements, _day(today));
    final entries = <GrazingEntry>[];
    for (final stay in stays) {
      entries.addAll(_withResources(stay, periods.where((p) => p.lotId == stay.lotId).toList(), lotNames));
    }
    final ongoing = animal.exitedAt == null;
    final merged = _merge(entries);
    if (ongoing && merged.isNotEmpty) {
      // El último tramo sigue hoy.
      final last = merged.removeLast();
      merged.add(last.copyWith(to: null));
    }
    return merged.reversed.toList();
  }

  static List<_Stay> _stays(GrazingAnimalSnapshot animal, List<GrazingMovement> movements, DateTime today) {
    final end = animal.exitedAt == null ? today : _day(animal.exitedAt!);
    final ordered = [...movements]
      ..sort((a, b) {
        final byDate = a.occurredAt.compareTo(b.occurredAt);
        return byDate != 0 ? byDate : a.createdAt.compareTo(b.createdAt);
      });
    final stays = <_Stay>[];

    if (ordered.isEmpty) {
      if (animal.currentLotId.isNotEmpty) {
        stays.add(_Stay(animal.currentLotId, _day(animal.createdAt), end, reason: GrazingEstimateReason.noMovements));
      }
      return _closeRanges(stays);
    }

    final first = ordered.first;
    final firstSource = first.sourceLotId;
    if (firstSource != null && firstSource.isNotEmpty) {
      final from = _min(_day(animal.createdAt), _day(first.occurredAt));
      stays.add(_Stay(firstSource, from, _day(first.occurredAt), reason: GrazingEstimateReason.beforeFirstMovement));
    }
    for (var i = 0; i < ordered.length; i++) {
      final movement = ordered[i];
      final next = i + 1 < ordered.length ? ordered[i + 1] : null;
      final nextSource = next?.sourceLotId;
      // La cadena se rompe si el siguiente movimiento sale de otro potrero:
      // en el medio hubo un cambio sin movimiento.
      final broken = nextSource != null && nextSource != movement.destinationLotId;
      stays.add(
        _Stay(
          movement.destinationLotId,
          _day(movement.occurredAt),
          next == null ? end : _day(next.occurredAt),
          reason: broken ? GrazingEstimateReason.brokenChain : null,
          pending: movement.pending,
        ),
      );
    }

    final last = ordered.last;
    if (animal.currentLotId.isNotEmpty && animal.currentLotId != last.destinationLotId) {
      // El lote actual cambió sin un movimiento: se corta cuando se editó.
      final cut = _max(_day(last.occurredAt), _day(animal.updatedAt));
      final lastStay = stays.removeLast();
      stays
        ..add(
          _Stay(
            lastStay.lotId,
            lastStay.from,
            cut,
            reason: lastStay.reason ?? GrazingEstimateReason.lotEditedWithoutMovement,
            pending: lastStay.pending,
          ),
        )
        ..add(_Stay(animal.currentLotId, cut, end, reason: GrazingEstimateReason.lotEditedWithoutMovement));
    }
    return _closeRanges(stays);
  }

  /// Cada estadía termina el día antes de la siguiente; se descartan las de
  /// largo cero (dos movimientos el mismo día: vale el último).
  static List<_Stay> _closeRanges(List<_Stay> stays) {
    final closed = <_Stay>[];
    for (var i = 0; i < stays.length; i++) {
      final stay = stays[i];
      final to = i + 1 < stays.length ? _addDays(stays[i + 1].from, -1) : stay.to;
      if (to.isBefore(stay.from)) continue;
      closed.add(_Stay(stay.lotId, stay.from, to, reason: stay.reason, pending: stay.pending));
    }
    return closed;
  }

  /// Parte la estadía según los recursos que tuvo el potrero.
  static List<GrazingEntry> _withResources(
    _Stay stay,
    List<GrazingForagePeriod> lotPeriods,
    Map<String, String> lotNames,
  ) {
    final sorted = [...lotPeriods]..sort((a, b) => a.startDate.compareTo(b.startDate));
    final lotName = lotNames[stay.lotId] ?? '';
    GrazingEntry entry(DateTime from, DateTime to, [GrazingForagePeriod? period]) => GrazingEntry(
      lotId: stay.lotId,
      lotName: lotName,
      from: from,
      to: to,
      resourceCode: period?.resourceCode,
      resourceDescription: period?.description,
      estimateReason: stay.reason,
      pending: stay.pending,
    );

    final result = <GrazingEntry>[];
    var cursor = stay.from;
    for (var i = 0; i < sorted.length; i++) {
      final period = sorted[i];
      final start = _day(period.startDate);
      final nextStart = i + 1 < sorted.length ? _addDays(_day(sorted[i + 1].startDate), -1) : null;
      final explicitEnd = period.endDate == null ? null : _day(period.endDate!);
      final periodEnd = switch ((explicitEnd, nextStart)) {
        (final a?, final b?) => _min(a, b),
        (final a?, null) => a,
        (null, final b?) => b,
        (null, null) => stay.to,
      };
      final from = _max(cursor, start);
      final to = _min(stay.to, periodEnd);
      if (to.isBefore(from)) continue;
      if (from.isAfter(cursor)) result.add(entry(cursor, _addDays(from, -1)));
      result.add(entry(from, to, period));
      cursor = _addDays(to, 1);
      if (cursor.isAfter(stay.to)) break;
    }
    if (!cursor.isAfter(stay.to)) result.add(entry(cursor, stay.to));
    return result;
  }

  /// Une tramos contiguos del mismo potrero y recurso.
  static List<GrazingEntry> _merge(List<GrazingEntry> entries) {
    final merged = <GrazingEntry>[];
    for (final entry in entries) {
      final previous = merged.isEmpty ? null : merged.last;
      if (previous != null &&
          previous.lotId == entry.lotId &&
          previous.resourceCode == entry.resourceCode &&
          previous.resourceDescription == entry.resourceDescription &&
          // Un tramo estimado no se une con uno respaldado por un movimiento:
          // si no, el tramo entero quedaría marcado como estimado.
          previous.estimateReason == entry.estimateReason &&
          previous.to != null &&
          !_addDays(previous.to!, 1).isBefore(entry.from)) {
        merged[merged.length - 1] = previous.copyWith(
          to: entry.to,
          pending: previous.pending || entry.pending,
        );
      } else {
        merged.add(entry);
      }
    }
    return merged;
  }

  static DateTime _day(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime _addDays(DateTime day, int days) => DateTime(day.year, day.month, day.day + days);
  static DateTime _min(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
  static DateTime _max(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
}

class _Stay {
  const _Stay(this.lotId, this.from, this.to, {this.reason, this.pending = false});

  final String lotId;
  final DateTime from;
  final DateTime to;
  final GrazingEstimateReason? reason;
  final bool pending;
}
