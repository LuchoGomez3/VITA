import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Datos ficticios del flujo de sanidad, usados para maquetar las pantallas
/// de vacunaciones, tratamientos, alertas y aplicar vacunación (ver
/// `.claude/specs/sanidad.md`).

/// Cantidad de registros de sincronización pendientes (mock fijo, mismo
/// número que la última alerta "Resincronizar 14 registros").
const int healthPendingSyncCount = 14;

/// Campaña de vacunación activa, con progreso sobre el objetivo.
@immutable
class HealthCampaignMock {
  /// Crea una campaña de vacunación mock.
  const HealthCampaignMock({
    required this.name,
    required this.targetDate,
    required this.applied,
    required this.target,
  });

  /// Nombre de la campaña (ej. `'Aftosa · campaña otoño'`).
  final String name;

  /// Fecha objetivo de cierre.
  final String targetDate;

  /// Cantidad de animales ya vacunados.
  final int applied;

  /// Cantidad total de animales objetivo.
  final int target;

  /// Progreso `[0, 1]` sobre el objetivo.
  double get progress => applied / target;
}

/// Campañas activas mostradas en la tab Vacunaciones.
const List<HealthCampaignMock> healthCampaignsMock = [
  HealthCampaignMock(name: 'Aftosa · campaña otoño', targetDate: '31/05/26', applied: 1248, target: 2847),
  HealthCampaignMock(name: 'Brucelosis (refuerzo)', targetDate: '15/06/26', applied: 216, target: 284),
  HealthCampaignMock(name: 'Clostridiales 10 vías', targetDate: '30/06/26', applied: 88, target: 612),
];

/// Vacunación programada dentro de los próximos 30 días.
@immutable
class ScheduledVaccinationMock {
  /// Crea una vacunación programada mock.
  const ScheduledVaccinationMock({
    required this.date,
    required this.title,
    required this.location,
    required this.animalCount,
  });

  /// Fecha programada (ej. `'22 MAY'`).
  final String date;

  /// Título de la vacunación.
  final String title;

  /// Potrero o grupo destino.
  final String location;

  /// Cantidad de animales incluidos.
  final int animalCount;
}

/// Vacunaciones programadas mostradas en la tab Vacunaciones.
const List<ScheduledVaccinationMock> healthScheduledMock = [
  ScheduledVaccinationMock(date: '22 MAY', title: 'Aftosa', location: 'Potrero La Loma', animalCount: 821),
  ScheduledVaccinationMock(date: '28 MAY', title: 'Aftosa', location: 'Potrero El Bajo', animalCount: 518),
  ScheduledVaccinationMock(
    date: '03 JUN',
    title: 'Refuerzo brucelosis',
    location: 'terneras años 24',
    animalCount: 68,
  ),
];

/// Tratamiento en curso, con período de carencia opcional.
@immutable
class TreatmentMock {
  /// Crea un tratamiento en curso mock.
  const TreatmentMock({
    required this.name,
    required this.batch,
    required this.detail,
    this.withdrawalNote,
  });

  /// Nombre del producto (ej. `'Ivermectina inyectable'`).
  final String name;

  /// Lote del producto (ej. `'IV-441'`).
  final String batch;

  /// Detalle libre (fecha de inicio, dosis, veterinario, animales).
  final String detail;

  /// Nota de carencia activa, si aplica.
  final String? withdrawalNote;
}

/// Tratamientos en curso mostrados en la tab Tratamientos.
const List<TreatmentMock> healthTreatmentsInProgressMock = [
  TreatmentMock(
    name: 'Ivermectina inyectable',
    batch: 'IV-441',
    detail: 'Iniciado 08/05/26',
    withdrawalNote: '14 animales no comercializables hasta 22/05/26',
  ),
  TreatmentMock(
    name: 'Antibiótico (mastitis)',
    batch: 'AB-220',
    detail: 'Dosis 2 de 3 · vet. C. Pérez · 3 animales · próxima dosis 17/05/26',
  ),
];

/// Entrada de historial de tratamientos (últimos 90 días).
@immutable
class TreatmentHistoryEntryMock {
  /// Crea una entrada de historial mock.
  const TreatmentHistoryEntryMock({required this.date, required this.title, required this.animalCount});

  /// Fecha del tratamiento.
  final String date;

  /// Nombre del tratamiento.
  final String title;

  /// Cantidad de animales tratados.
  final int animalCount;
}

/// Historial de tratamientos de los últimos 90 días.
const List<TreatmentHistoryEntryMock> healthTreatmentHistoryMock = [
  TreatmentHistoryEntryMock(date: '02/05/26', title: 'Vermífugo oral', animalCount: 142),
  TreatmentHistoryEntryMock(date: '14/04/26', title: 'Antiparasitario', animalCount: 88),
  TreatmentHistoryEntryMock(date: '08/03/26', title: 'Vitaminas + minerales', animalCount: 612),
];

/// Tono semántico de una alerta sanitaria.
enum HealthAlertTone {
  /// Requiere atención inmediata.
  danger,

  /// Requiere atención próximamente.
  warn,

  /// Informativa, sin urgencia.
  info,
}

/// Alerta de la bandeja unificada de Sanidad.
@immutable
class HealthAlertMock {
  /// Crea una alerta sanitaria mock.
  const HealthAlertMock({
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  /// Tono semántico de la alerta.
  final HealthAlertTone tone;

  /// Título de la alerta.
  final String title;

  /// Subtítulo con el detalle.
  final String subtitle;

  /// Texto de la acción asociada (ej. `'Ver →'`).
  final String actionLabel;
}

/// Bandeja plana de alertas mostrada en la tab Alertas.
///
/// La última alerta ("Resincronizar 14 registros") es el hook de sync
/// pendiente, con el mismo número que [healthPendingSyncCount].
const List<HealthAlertMock> healthAlertsMock = [
  HealthAlertMock(
    tone: HealthAlertTone.danger,
    title: '14 animales en carencia activa',
    subtitle: 'Trat. ivermectina · hasta 22/05/26',
    actionLabel: 'Ver →',
  ),
  HealthAlertMock(
    tone: HealthAlertTone.danger,
    title: '3 animales con vacuna vencida',
    subtitle: 'Brucelosis · vencida hace 8 días',
    actionLabel: 'Aplicar →',
  ),
  HealthAlertMock(
    tone: HealthAlertTone.warn,
    title: '23 terneras con vacunación próxima a vencer',
    subtitle: 'Brucelosis · vence 18/05/26',
    actionLabel: 'Programar →',
  ),
  HealthAlertMock(
    tone: HealthAlertTone.warn,
    title: 'Tratamiento sin seguimiento',
    subtitle: 'Antibiótico AB-220 · próxima dosis 17/05',
    actionLabel: 'Marcar →',
  ),
  HealthAlertMock(
    tone: HealthAlertTone.info,
    title: '86 animales pendientes de aftosa',
    subtitle: 'Campaña otoño · cierre 31/05/26',
    actionLabel: 'Programar →',
  ),
  HealthAlertMock(
    tone: HealthAlertTone.info,
    title: 'Resincronizar $healthPendingSyncCount registros',
    subtitle: 'Vacunaciones y pesajes locales',
    actionLabel: 'Reintentar →',
  ),
];

/// Caravana mock seleccionada en Aplicar vacunación.
@immutable
class ApplyVaccinationEarTagMock {
  /// Crea una caravana mock con su color de plástico.
  const ApplyVaccinationEarTagMock({required this.visualTag, required this.color});

  /// Número visual de la caravana.
  final String visualTag;

  /// Color de plástico de la caravana.
  final Color color;
}

/// Subtítulo de campaña de la pantalla de aplicar vacunación.
const String applyVaccinationCampaignSubtitle = 'Campaña aftosa · otoño 2026';

/// Caravanas mock ya seleccionadas para aplicar la vacunación.
const List<ApplyVaccinationEarTagMock> applyVaccinationEarTagsMock = [
  ApplyVaccinationEarTagMock(visualTag: '003 1284', color: AppColors.earTagYellow),
  ApplyVaccinationEarTagMock(visualTag: '003 1287', color: AppColors.earTagYellow),
  ApplyVaccinationEarTagMock(visualTag: '003 1290', color: AppColors.earTagYellow),
  ApplyVaccinationEarTagMock(visualTag: '004 0023', color: AppColors.backgroundTertiary),
  ApplyVaccinationEarTagMock(visualTag: '004 0028', color: AppColors.backgroundTertiary),
  ApplyVaccinationEarTagMock(visualTag: '005 0772', color: AppColors.earTagCeleste),
];

/// Producto/vacuna mock preseleccionado.
const String applyVaccinationProductMock = 'Vacuna antiaftosa Aftogen Oleo';

/// Lote mock del producto.
const String applyVaccinationBatchMock = '2025-09-AFT';

/// Dosis mock, en mililitros.
const String applyVaccinationDoseMlMock = '2,0';

/// Fecha de aplicación mock.
final DateTime applyVaccinationDateMock = DateTime(2026, 5, 15);

/// Días de carencia del producto mock.
const int applyVaccinationWithdrawalDays = 14;

/// Mensaje de carencia mostrado en el callout.
const String applyVaccinationWithdrawalMessage =
    'Hasta el 29/05/26 estos 6 animales no podrán ser comercializados.';
