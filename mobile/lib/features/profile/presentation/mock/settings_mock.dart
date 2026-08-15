/// Un dispositivo Bluetooth emparejado mock.
class PairedDeviceMock {
  /// Crea un dispositivo mock.
  const PairedDeviceMock({required this.name, required this.detail, required this.isConnected});

  /// Nombre comercial del dispositivo.
  final String name;

  /// Detalle combinado (tipo · identificador · estado), igual que el diseño.
  final String detail;

  /// Si el dispositivo está conectado (colorea el detalle en verde).
  final bool isConnected;
}

/// Los 2 dispositivos mock ya emparejados (ver `.claude/specs/ajustes.md`).
const pairedDevicesMock = [
  PairedDeviceMock(name: 'Tru-Test GES3S', detail: 'Bastón RFID · #4421 · conectado', isConnected: true),
  PairedDeviceMock(name: 'Magris MC-200', detail: 'Balanza · #M9012 · conectada', isConnected: true),
];

/// Una fila informativa de sólo lectura (Preferencias / Sobre la app).
class SettingsInfoMock {
  /// Crea una fila informativa mock.
  const SettingsInfoMock({required this.label, this.value, this.isNavigable = true});

  /// Etiqueta de la fila.
  final String label;

  /// Valor mock mostrado como subtítulo, si corresponde.
  final String? value;

  /// Si la fila muestra chevron de navegación (sin destino real en Etapa 1).
  final bool isNavigable;
}

/// Sección "Preferencias": todas navegables, sin funcionalidad real todavía.
const preferencesMock = [
  SettingsInfoMock(label: 'Tema', value: 'Automático (claro / oscuro)'),
  SettingsInfoMock(label: 'Idioma', value: 'Español (Argentina)'),
  SettingsInfoMock(label: 'Unidades', value: 'kg · ha · DD/MM/AAAA'),
];

/// Sección "Sobre la app": "Versión" no es navegable (dato de sólo lectura).
const aboutAppMock = [
  SettingsInfoMock(label: 'Manual de usuario'),
  SettingsInfoMock(label: 'Soporte', value: 'soporte@hacienda.app'),
  SettingsInfoMock(label: 'Versión', value: 'v0.9.3 · build 412', isNavigable: false),
];
