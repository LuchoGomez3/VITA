import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';

LotForagePeriod _period(String id, DateTime start, {DateTime? end, String code = 'avena'}) => LotForagePeriod(
  id: id,
  establishmentId: 'est-1',
  lotId: 'lot-1',
  resourceCode: code,
  startDate: start,
  endDate: end,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  group('LotForageTimeline.current', () {
    test('es el período más reciente aunque llegue desordenado', () {
      final periods = [
        _period('b', DateTime(2026, 6), code: 'sorgo'),
        _period('a', DateTime(2026, 2)),
      ];

      expect(LotForageTimeline.current(periods)?.resourceCode, 'sorgo');
    });

    test('un corte en el más reciente deja el potrero sin recurso', () {
      final periods = [
        _period('a', DateTime(2026, 2)),
        _period('b', DateTime(2026, 6), end: DateTime(2026, 8)),
      ];

      expect(LotForageTimeline.current(periods), isNull);
    });

    test('sin historial no hay recurso vigente', () {
      expect(LotForageTimeline.current(const []), isNull);
    });
  });

  group('LotForageTimeline.effectiveEnd', () {
    test('termina el día antes del siguiente período', () {
      final first = _period('a', DateTime(2026, 2));
      final periods = [first, _period('b', DateTime(2026, 3))];

      expect(LotForageTimeline.effectiveEnd(first, periods), DateTime(2026, 2, 28));
    });

    test('un corte anterior al siguiente período gana', () {
      final first = _period('a', DateTime(2026, 2), end: DateTime(2026, 2, 10));
      final periods = [first, _period('b', DateTime(2026, 3))];

      expect(LotForageTimeline.effectiveEnd(first, periods), DateTime(2026, 2, 10));
    });

    test('el último sin corte sigue vigente', () {
      final last = _period('b', DateTime(2026, 3));

      expect(LotForageTimeline.effectiveEnd(last, [_period('a', DateTime(2026, 2)), last]), isNull);
    });
  });

  test('newestFirst ordena del más reciente al más antiguo', () {
    final ordered = LotForageTimeline.newestFirst([
      _period('a', DateTime(2026, 2)),
      _period('c', DateTime(2026, 9)),
      _period('b', DateTime(2026, 5)),
    ]);

    expect(ordered.map((p) => p.id), ['c', 'b', 'a']);
  });
}
