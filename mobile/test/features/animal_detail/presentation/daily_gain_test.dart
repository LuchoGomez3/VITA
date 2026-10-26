import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_weighings_tab.dart';

void main() {
  AnimalWeightRecord record(double kg, DateTime date) =>
      AnimalWeightRecord(id: '$kg', weightKg: kg, date: date, method: AnimalWeighingMethod.manual);

  test('a weight loss gives a negative daily gain, shown in red with a minus sign', () {
    final gain = dailyGainBetween(record(388, DateTime(2026, 10, 8)), record(370, DateTime(2026, 10, 14)))!;

    expect(gain, closeTo(-3, 1e-9));
    expect(formatDailyGain(gain), '−3,00');
    expect(dailyGainTone(gain), AppStatusChipTone.error);
  });

  test('a weight gain is green with a plus sign', () {
    final gain = dailyGainBetween(record(374, DateTime(2026, 9, 8)), record(388, DateTime(2026, 10, 8)))!;

    expect(formatDailyGain(gain), '+0,47');
    expect(dailyGainTone(gain), AppStatusChipTone.success);
  });

  test('two weighings on the same moment have no daily gain', () {
    final date = DateTime(2026, 10, 8);

    expect(dailyGainBetween(record(380, date), record(388, date)), isNull);
  });
}
