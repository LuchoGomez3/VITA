import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';

void main() {
  group('LotStatus.fromCode', () {
    test('acepta los codigos actuales del backend', () {
      expect(LotStatus.fromCode('activo'), LotStatus.active);
      expect(LotStatus.fromCode('descanso'), LotStatus.resting);
      expect(LotStatus.fromCode('mantenimiento'), LotStatus.maintenance);
      expect(LotStatus.fromCode('inactivo'), LotStatus.inactive);
    });

    test('no conserva fallback para los codigos viejos del frontend', () {
      expect(LotStatus.fromCode('active'), LotStatus.unknown);
      expect(LotStatus.fromCode('resting'), LotStatus.unknown);
      expect(LotStatus.fromCode('maintenance'), LotStatus.unknown);
      expect(LotStatus.fromCode('inactive'), LotStatus.unknown);
    });
  });
}
