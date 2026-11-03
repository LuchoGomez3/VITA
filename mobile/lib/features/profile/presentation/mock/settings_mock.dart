import 'package:flutter/material.dart';

/// Un dispositivo Bluetooth emparejado mock.
class PairedDeviceMock {
  /// Crea un dispositivo mock.
  const PairedDeviceMock({
    required this.name,
    required this.detail,
    required this.icon,
    required this.isConnected,
  });

  /// Nombre comercial del dispositivo.
  final String name;

  /// Detalle combinado (tipo · identificador · estado), igual que el diseño.
  final String detail;

  /// Icono según el tipo de dispositivo (bastón RFID o balanza).
  final IconData icon;

  /// Si el dispositivo está conectado (colorea el detalle en verde).
  final bool isConnected;
}

/// Los 2 dispositivos mock ya emparejados (ver `.claude/specs/ajustes.md`).
const pairedDevicesMock = [
  PairedDeviceMock(
    name: 'Tru-Test GES3S',
    detail: 'Bastón RFID · #4421 · conectado',
    icon: Icons.bluetooth,
    isConnected: true,
  ),
  PairedDeviceMock(
    name: 'Magris MC-200',
    detail: 'Balanza · #M9012 · conectada',
    icon: Icons.scale_outlined,
    isConnected: true,
  ),
];

/// Una fila informativa de sólo lectura (Preferencias / Sobre la app).
class SettingsInfoMock {
  /// Crea una fila informativa mock.
  const SettingsInfoMock({
    required this.label,
    required this.icon,
    this.value,
  });

  /// Etiqueta de la fila.
  final String label;

  /// Icono de la fila.
  final IconData icon;

  /// Valor mock mostrado como subtítulo, si corresponde.
  final String? value;
}

/// Sección "Preferencias": todas navegables, sin funcionalidad real todavía.
const preferencesMock = [
  SettingsInfoMock(
    label: 'Tema',
    icon: Icons.contrast,
    value: 'Automático (claro / oscuro)',
  ),
  SettingsInfoMock(
    label: 'Idioma',
    icon: Icons.translate,
    value: 'Español (Argentina)',
  ),
  SettingsInfoMock(
    label: 'Unidades',
    icon: Icons.straighten,
    value: 'kg · ha · DD/MM/AAAA',
  ),
];

/// Sección "Sobre la app", sin la versión: esa se lee del paquete instalado.
const aboutAppMock = [
  SettingsInfoMock(label: 'Manual de usuario', icon: Icons.menu_book_outlined),
  SettingsInfoMock(
    label: 'Soporte',
    icon: Icons.support_agent,
    value: 'soporte@hacienda.app',
  ),
];
