import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Datos ficticios de un animal a pesar, usados para maquetar la pantalla de
/// pesaje en manga (ver `.claude/specs/pesaje-en-manga.md`).
@immutable
class WeighingAnimalMock {
  /// Crea un animal mock para la cola de pesaje.
  const WeighingAnimalMock({
    required this.visualTag,
    required this.rfid,
    required this.breedAndCategory,
    required this.weightKg,
  });

  /// Número visual de la caravana (ej. `'003 1284'`).
  final String visualTag;

  /// Código RFID completo de la caravana.
  final String rfid;

  /// Raza y categoría combinadas (ej. `'Aberdeen Angus · Vaca'`).
  final String breedAndCategory;

  /// Peso capturado, en kilogramos.
  final int weightKg;
}

/// Color de plástico de caravana asignado al animal mock actual.
const Color weighingEarTagColor = AppColors.earTagYellow;

/// GPD mock fijo respecto del pesaje anterior, en kg/día.
///
/// No se deriva de pesajes reales — ver "Explícitamente fuera de alcance" en
/// `.claude/specs/pesaje-en-manga.md`.
const String weighingGpdDelta = '+0,85';

/// Balanza Bluetooth mock, siempre reportada como conectada y estable.
const String weighingScaleName = 'Balanza Magris MC-200';

/// Total de animales del lote mock.
const int weighingBatchTotal = 142;

/// Posición inicial dentro del lote mock.
const int weighingBatchStart = 8;

/// Cola de animales mock que se van pesando en la manga, en orden.
const List<WeighingAnimalMock> weighingBatchMock = [
  WeighingAnimalMock(
    visualTag: '003 1284',
    rfid: '982 000 412 884 712',
    breedAndCategory: 'Aberdeen Angus · Vaca',
    weightKg: 442,
  ),
  WeighingAnimalMock(
    visualTag: '003 1285',
    rfid: '982 000 412 884 713',
    breedAndCategory: 'Aberdeen Angus · Vaquillona',
    weightKg: 318,
  ),
  WeighingAnimalMock(
    visualTag: '003 1286',
    rfid: '982 000 412 884 714',
    breedAndCategory: 'Hereford · Novillo',
    weightKg: 401,
  ),
];
