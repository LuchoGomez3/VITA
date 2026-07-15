import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';

void main() {
  group('brickPesoFromBackend', () {
    test('parsea el peso serializado como string por el backend', () {
      // El backend serializa Numeric como string ("185.500").
      expect(brickPesoFromBackend('185.500'), 185.5);
    });

    test('tolera numeros directos', () {
      expect(brickPesoFromBackend(200), 200.0);
      expect(brickPesoFromBackend(190.25), 190.25);
    });

    test('cae a 0 ante valores ausentes o invalidos', () {
      expect(brickPesoFromBackend(null), 0);
      expect(brickPesoFromBackend('no-numero'), 0);
    });
  });

  group('brickNullablePesoFromBackend', () {
    test('preserva null para campos opcionales', () {
      expect(brickNullablePesoFromBackend(null), isNull);
    });

    test('parsea la condicion corporal cuando viene', () {
      expect(brickNullablePesoFromBackend('3.5'), 3.5);
    });
  });

  group('metodo de pesaje', () {
    test('mapea el enum del backend al enum local', () {
      expect(
        brickPesajeMethodFromBackend('balanza_bluetooth'),
        BrickPesajeMethod.bluetoothScale,
      );
      expect(
        brickPesajeMethodFromBackend('estimacion_ia'),
        BrickPesajeMethod.artificialIntelligence,
      );
      expect(
        brickPesajeMethodFromBackend('manual'),
        BrickPesajeMethod.manual,
      );
    });

    test('un valor desconocido o nulo cae a manual', () {
      expect(brickPesajeMethodFromBackend(null), BrickPesajeMethod.manual);
      expect(brickPesajeMethodFromBackend('otro'), BrickPesajeMethod.manual);
    });

    test('el ida y vuelta con el contrato backend es estable', () {
      for (final metodo in BrickPesajeMethod.values) {
        final backendValue = brickPesajeMethodToBackend(metodo);
        expect(brickPesajeMethodFromBackend(backendValue), metodo);
      }
    });
  });

  group('brickPesajeDateTimeFromBackend', () {
    test('parsea una fecha ISO 8601', () {
      expect(
        brickPesajeDateTimeFromBackend('2025-05-01T09:00:00Z'),
        DateTime.utc(2025, 5, 1, 9),
      );
    });

    test('cae al epoch ante fechas ausentes', () {
      expect(
        brickPesajeDateTimeFromBackend(null),
        DateTime.fromMillisecondsSinceEpoch(0),
      );
    });
  });
}
