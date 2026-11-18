import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:frontend_mayoral/features/feeding/domain/services/grazing_history_builder.dart';

const _names = {'bajo': 'El Bajo', 'cumbre': 'La Cumbre', 'sauces': 'Los Sauces'};
final _today = DateTime(2026, 11, 17, 10);

GrazingAnimalSnapshot _animal({
  String lot = 'cumbre',
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? exitedAt,
}) => GrazingAnimalSnapshot(
  createdAt: createdAt ?? DateTime(2026, 6),
  updatedAt: updatedAt ?? DateTime(2026, 6),
  currentLotId: lot,
  exitedAt: exitedAt,
);

GrazingMovement _move(String? from, String to, DateTime at, {bool pending = false}) =>
    GrazingMovement(occurredAt: at, createdAt: at, sourceLotId: from, destinationLotId: to, pending: pending);

GrazingForagePeriod _period(String lot, String code, DateTime start, {DateTime? end}) =>
    GrazingForagePeriod(lotId: lot, resourceCode: code, startDate: start, endDate: end);

List<GrazingEntry> _build({
  GrazingAnimalSnapshot? animal,
  List<GrazingMovement> movements = const [],
  List<GrazingForagePeriod> periods = const [],
}) => GrazingHistoryBuilder.build(
  animal: animal ?? _animal(),
  movements: movements,
  periods: periods,
  lotNames: _names,
  today: _today,
);

void main() {
  test('sin movimientos: un tramo estimado en el potrero actual desde el alta', () {
    final entries = _build(periods: [_period('cumbre', 'avena', DateTime(2026))]);

    expect(entries, hasLength(1));
    expect(entries.single.lotName, 'La Cumbre');
    expect(entries.single.resourceCode, 'avena');
    expect(entries.single.from, DateTime(2026, 6));
    expect(entries.single.to, isNull, reason: 'sigue hoy');
    expect(entries.single.estimateReason, GrazingEstimateReason.noMovements);
  });

  test('sin potrero ni movimientos no hay pastoreo', () {
    expect(_build(animal: _animal(lot: '')), isEmpty);
  });

  test('cadena completa: un tramo por potrero, del más reciente al más antiguo', () {
    final entries = _build(
      movements: [
        _move('bajo', 'sauces', DateTime(2026, 8)),
        _move('sauces', 'cumbre', DateTime(2026, 10)),
      ],
      periods: [
        _period('bajo', 'pasto_natural', DateTime(2026)),
        _period('sauces', 'sorgo', DateTime(2026)),
        _period('cumbre', 'avena', DateTime(2026)),
      ],
    );

    expect(entries.map((e) => e.lotId), ['cumbre', 'sauces', 'bajo']);
    expect(entries.map((e) => e.resourceCode), ['avena', 'sorgo', 'pasto_natural']);
    // Cada tramo termina el día antes del siguiente.
    expect(entries[1].from, DateTime(2026, 8));
    expect(entries[1].to, DateTime(2026, 9, 30));
    // Solo el primero (origen anterior al primer movimiento) es inferido.
    expect(entries.map((e) => e.estimateReason), [null, null, GrazingEstimateReason.beforeFirstMovement]);
  });

  test('un cambio de recurso parte la estadía en el potrero', () {
    final entries = _build(
      movements: [_move(null, 'cumbre', DateTime(2026, 6))],
      periods: [
        _period('cumbre', 'avena', DateTime(2026)),
        _period('cumbre', 'rastrojo_maiz', DateTime(2026, 9)),
      ],
    );

    expect(entries.map((e) => e.resourceCode), ['rastrojo_maiz', 'avena']);
    expect(entries.last.to, DateTime(2026, 8, 31));
    expect(entries.first.from, DateTime(2026, 9));
  });

  test('los tramos sin recurso cargado quedan como "sin registrar"', () {
    final entries = _build(
      movements: [_move(null, 'cumbre', DateTime(2026, 6))],
      periods: [_period('cumbre', 'avena', DateTime(2026, 8), end: DateTime(2026, 9, 15))],
    );

    expect(entries.map((e) => e.resourceCode), [null, 'avena', null]);
    expect(entries[1].from, DateTime(2026, 8));
    expect(entries[1].to, DateTime(2026, 9, 15));
  });

  test('cadena rota: el destino de un movimiento no coincide con el origen del siguiente', () {
    final entries = _build(
      movements: [
        _move(null, 'bajo', DateTime(2026, 6)),
        _move('sauces', 'cumbre', DateTime(2026, 9)),
      ],
    );

    final bajo = entries.singleWhere((e) => e.lotId == 'bajo');
    expect(bajo.estimateReason, GrazingEstimateReason.brokenChain);
  });

  test('lote editado sin movimiento: corta en la edición y agrega el potrero actual', () {
    final entries = _build(
      animal: _animal(lot: 'sauces', updatedAt: DateTime(2026, 10, 5, 14)),
      movements: [_move(null, 'bajo', DateTime(2026, 6))],
    );

    expect(entries.map((e) => e.lotId), ['sauces', 'bajo']);
    expect(entries.first.from, DateTime(2026, 10, 5));
    expect(entries.map((e) => e.estimateReason), everyElement(GrazingEstimateReason.lotEditedWithoutMovement));
  });

  test('los movimientos pendientes marcan su tramo', () {
    final entries = _build(
      movements: [
        _move(null, 'bajo', DateTime(2026, 6)),
        _move('bajo', 'cumbre', DateTime(2026, 11, 16), pending: true),
      ],
    );

    expect(entries.first.lotId, 'cumbre');
    expect(entries.first.pending, isTrue);
    expect(entries.last.pending, isFalse);
  });

  test('un animal vendido termina su pastoreo el día de la venta', () {
    final entries = _build(
      animal: _animal(exitedAt: DateTime(2026, 9, 20)),
      movements: [_move(null, 'cumbre', DateTime(2026, 6))],
    );

    expect(entries.single.to, DateTime(2026, 9, 20));
  });

  test('dos movimientos el mismo día: vale el último', () {
    final entries = _build(
      movements: [
        _move(null, 'bajo', DateTime(2026, 6)),
        _move('bajo', 'sauces', DateTime(2026, 8, 1, 9)),
        _move('sauces', 'cumbre', DateTime(2026, 8, 1, 17)),
      ],
    );

    expect(entries.map((e) => e.lotId), ['cumbre', 'bajo']);
  });

  test('usa el día local aunque el movimiento venga en UTC', () {
    // 02:00 UTC del 1/8 es todavía 31/7 en Córdoba (UTC-3).
    final utc = DateTime.utc(2026, 8, 1, 2);
    final entries = _build(movements: [_move(null, 'cumbre', utc)]);

    final local = utc.toLocal();
    expect(entries.single.from, DateTime(local.year, local.month, local.day));
  });

  test('vuelve al mismo potrero el mismo día: el tramo confirmado no se marca como estimado', () {
    // Caso real de la 004 0023: sale y vuelve a El Bajo el mismo día.
    final entries = _build(
      animal: _animal(lot: 'bajo', createdAt: DateTime(2026, 10, 14)),
      movements: [
        _move('bajo', 'sauces', DateTime(2026, 11, 3, 9)),
        _move('sauces', 'bajo', DateTime(2026, 11, 3, 17)),
      ],
    );

    expect(entries, hasLength(2));
    expect(entries.first.from, DateTime(2026, 11, 3));
    expect(entries.first.estimateReason, isNull);
    expect(entries.last.to, DateTime(2026, 11, 2));
    expect(entries.last.estimateReason, GrazingEstimateReason.beforeFirstMovement);
  });
}
