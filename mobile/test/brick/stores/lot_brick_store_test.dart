import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';

void main() {
  group('BrickLotStore.selectLocalLots', () {
    test('el historial conserva el último tombstone y mantiene el aislamiento', () {
      final lots = [
        _lot(id: '1', establishmentId: 'est-1', name: 'Viejo'),
        _lot(
          id: '1',
          establishmentId: 'est-1',
          name: 'Lote eliminado',
          updatedAt: DateTime.utc(2026, 9),
          deletedAt: DateTime.utc(2026, 9),
        ),
        _lot(id: 'ajeno', establishmentId: 'est-2', name: 'Ajeno'),
      ];

      expect(BrickLotStore.selectLocalLots(lots, establishmentId: 'est-1'), isEmpty);
      final historyLots = BrickLotStore.selectLocalLots(lots, establishmentId: 'est-1', includeDeleted: true);
      expect(historyLots.single.name, 'Lote eliminado');
      expect(historyLots.single.deletedAt, isNotNull);
    });
    test('aísla por establecimiento y ordena por nombre', () {
      final selected = BrickLotStore.selectLocalLots(
        [
          _lot(id: '2', establishmentId: 'est-1', name: 'Sur'),
          _lot(id: '3', establishmentId: 'est-2', name: 'Ajeno'),
          _lot(id: '1', establishmentId: 'est-1', name: 'Norte'),
        ],
        establishmentId: 'est-1',
      );

      expect(selected.map((lot) => lot.localId), ['1', '2']);
    });

    test('conserva la versión más nueva y excluye tombstones', () {
      final selected = BrickLotStore.selectLocalLots(
        [
          _lot(id: '1', establishmentId: 'est-1', name: 'Anterior'),
          _lot(
            id: '1',
            establishmentId: 'est-1',
            name: 'Eliminado',
            updatedAt: DateTime.utc(2026, 8, 29),
            deletedAt: DateTime.utc(2026, 8, 29),
          ),
        ],
        establishmentId: 'est-1',
      );

      expect(selected, isEmpty);
    });
  });

  test('copyWith permite limpiar el ultimo error de sincronizacion', () {
    final rejected =
        _lot(
          id: 'sync-lot',
          establishmentId: 'est-1',
          name: 'Rechazado',
        ).copyWith(
          syncStatus: BrickLotSyncStatus.rejected,
          syncErrorCode: 'duplicate_name',
        );

    final synchronized = rejected.copyWith(
      syncStatus: BrickLotSyncStatus.synchronized,
      syncErrorCode: null,
    );

    expect(synchronized.syncErrorCode, isNull);
    expect(synchronized.syncStatus, BrickLotSyncStatus.synchronized);
  });
}

BrickLotModel _lot({
  required String id,
  required String establishmentId,
  required String name,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final timestamp = updatedAt ?? DateTime.utc(2026, 8, 28);
  return BrickLotModel(
    localId: id,
    establishmentId: establishmentId,
    name: name,
    boundaryJson: '{}',
    surfaceTenths: 100,
    hasWater: true,
    statusCode: 'activo',
    createdAt: DateTime.utc(2026, 8, 28),
    updatedAt: timestamp,
    deletedAt: deletedAt,
  );
}
