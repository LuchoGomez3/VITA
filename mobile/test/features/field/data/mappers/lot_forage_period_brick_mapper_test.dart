import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/lot_forage_period.model.dart';
import 'package:frontend_mayoral/features/field/data/mappers/lot_forage_period_brick_mapper.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';

void main() {
  test('las fechas viajan como día calendario sin corrimiento horario', () {
    final period = LotForagePeriod(
      id: 'p-1',
      establishmentId: 'est-1',
      lotId: 'lot-1',
      resourceCode: 'rastrojo_maiz',
      startDate: DateTime(2026, 3),
      endDate: DateTime(2026, 12, 31),
      createdAt: DateTime.utc(2026, 3),
      updatedAt: DateTime.utc(2026, 3),
    );

    final model = LotForagePeriodBrickMapper.toBrick(period);

    expect(model.startDate, '2026-03-01');
    expect(model.endDate, '2026-12-31');
    expect(LotForagePeriodBrickMapper.fromBrick(model).startDate, DateTime(2026, 3));
  });

  test('traduce el estado de sincronización', () {
    final model = BrickLotForagePeriodModel(
      localId: 'p-1',
      establishmentId: 'est-1',
      lotId: 'lot-1',
      forageResourceCode: 'avena',
      startDate: '2026-05-01',
      createdAt: DateTime.utc(2026, 5),
      updatedAt: DateTime.utc(2026, 5),
      syncStatus: BrickLotForagePeriodSyncStatus.rejected,
      syncErrorCode: 'periodo_recurso_duplicado',
    );

    final period = LotForagePeriodBrickMapper.fromBrick(model);

    expect(period.syncStatus, LotSyncStatus.rejected);
    expect(period.syncErrorCode, 'periodo_recurso_duplicado');
    expect(period.endDate, isNull);
  });
}
