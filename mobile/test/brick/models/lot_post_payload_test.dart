import 'package:brick_rest/brick_rest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';

void main() {
  test('serializa los estados locales según el contrato del POST de lotes', () async {
    final adapter = BrickLotModelAdapter();
    final provider = RestProvider('http://localhost:8000', modelDictionary: restModelDictionary);
    final timestamp = DateTime.utc(2026, 10, 5);
    const states = {
      'active': 'activo',
      'resting': 'descanso',
      'maintenance': 'mantenimiento',
      'inactive': 'inactivo',
      'activo': 'activo',
      'descanso': 'descanso',
      'mantenimiento': 'mantenimiento',
      'inactivo': 'inactivo',
    };
    for (final entry in states.entries) {
      final lot = BrickLotModel(
        localId: 'dc4f8ad8-4818-4bf6-b917-fc45af3b0485',
        establishmentId: 'e35a810e-2740-4ca0-a387-e4aa372dac69',
        name: 'Norte',
        boundaryJson: '{"version":1}',
        surfaceTenths: 457,
        hasWater: true,
        statusCode: entry.key,
        createdAt: timestamp,
        updatedAt: timestamp,
      );
      // Prueba el adapter generado, que construye el body real de Brick.
      final body = await adapter.toRest(lot, provider: provider);
      expect(body['estado'], entry.value);
      expect(body['modo_geometria'], 'local_schematic');
      expect(body['superficie_ha'], 45.7);
      expect(body['geometria_local'], {'version': 1});
      expect(body.containsKey('sync_status'), isFalse);
    }
  });
}
