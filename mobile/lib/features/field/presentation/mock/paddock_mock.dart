import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Nivel de carga animal de un potrero, usado para colorear mapa y lista.
enum PaddockDensity {
  /// Sin carga (potrero libre).
  none,

  /// Carga baja.
  low,

  /// Carga media.
  medium,

  /// Carga alta.
  high;

  /// Color asociado a este nivel de densidad.
  Color get color => switch (this) {
    PaddockDensity.none => AppColors.border,
    PaddockDensity.low => AppColors.backgroundSecondary,
    PaddockDensity.medium => AppColors.earTagBlue,
    PaddockDensity.high => AppColors.primary,
  };
}

/// Datos ficticios de un potrero, usados para maquetar mapa/lista/detalle.
@immutable
class Paddock {
  /// Crea un potrero mock.
  const Paddock({
    required this.id,
    required this.name,
    required this.hectares,
    required this.headCount,
    required this.forage,
    required this.lastMovement,
    required this.density,
  });

  /// Identificador usado en la ruta de detalle.
  final String id;

  /// Nombre del potrero.
  final String name;

  /// Superficie en hectáreas.
  final double hectares;

  /// Cabezas de ganado actuales.
  final int headCount;

  /// Descripción del recurso forrajero, o `null` si está libre.
  final String? forage;

  /// Texto del último movimiento registrado.
  final String lastMovement;

  /// Nivel de carga, usado para colorear mapa y lista.
  final PaddockDensity density;

  /// Si el potrero no tiene animales.
  bool get isEmpty => headCount == 0;
}

/// Potreros ficticios de "La Sirena", en el mismo orden que el diseño.
const paddocksMock = <Paddock>[
  Paddock(
    id: 'la-loma',
    name: 'La Loma',
    hectares: 218,
    headCount: 821,
    forage: 'Mixta · alfalfa + gramíneas',
    lastMovement: 'Mov. 08/05',
    density: PaddockDensity.high,
  ),
  Paddock(
    id: 'el-bajo',
    name: 'El Bajo',
    hectares: 184,
    headCount: 518,
    forage: 'Pastura natural',
    lastMovement: 'Mov. 22/04',
    density: PaddockDensity.medium,
  ),
  Paddock(
    id: 'san-jose',
    name: 'San José',
    hectares: 96,
    headCount: 412,
    forage: 'Sorgo diferido',
    lastMovement: 'Mov. 02/05',
    density: PaddockDensity.medium,
  ),
  Paddock(
    id: 'la-toma',
    name: 'La Toma',
    hectares: 142,
    headCount: 352,
    forage: 'Avena',
    lastMovement: 'Mov. 30/04',
    density: PaddockDensity.high,
  ),
  Paddock(
    id: 'la-cumbre',
    name: 'La Cumbre',
    hectares: 142,
    headCount: 342,
    forage: 'Pastura natural',
    lastMovement: 'Mov. 14/03',
    density: PaddockDensity.low,
  ),
  Paddock(
    id: 'el-tala',
    name: 'El Tala',
    hectares: 88,
    headCount: 274,
    forage: 'Mixta',
    lastMovement: 'Mov. 18/04',
    density: PaddockDensity.low,
  ),
  Paddock(
    id: 'los-sauces',
    name: 'Los Sauces',
    hectares: 64,
    headCount: 128,
    forage: 'Reserva',
    lastMovement: 'Mov. 10/05',
    density: PaddockDensity.none,
  ),
  Paddock(
    id: 'aguada-vieja',
    name: 'Aguada Vieja',
    hectares: 12,
    headCount: 0,
    forage: null,
    lastMovement: 'Libre desde 08/05',
    density: PaddockDensity.none,
  ),
];

/// Cantidad total de potreros del establecimiento mock.
int get paddocksTotalCount => paddocksMock.length;

/// Hectáreas totales del establecimiento mock.
double get paddocksTotalHectares => paddocksMock.fold(0, (sum, p) => sum + p.hectares);

/// Cabezas totales del establecimiento mock.
int get paddocksTotalHeadCount => paddocksMock.fold(0, (sum, p) => sum + p.headCount);

/// Historial de ocupación mock para el detalle de "La Loma".
const laLomaOccupationHistory = <(String, String)>[
  ('08/05 → hoy', '821 cab'),
  ('22/04 → 08/05', '604 cab'),
  ('01/03 → 22/04', 'libre · descanso'),
  ('12/01 → 01/03', '780 cab'),
];

/// Desglose por categoría mock para el detalle de "La Loma".
const laLomaComposition = <(String, int)>[
  ('Vacas', 612),
  ('Terneros', 168),
  ('Toros', 7),
  ('Vaquillonas', 34),
];
