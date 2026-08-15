/// Etiqueta mock de "hace cuánto" fue la última sincronización.
const syncStatusLastSyncLabel = 'hace 2 min';

/// Cantidad de registros pendientes de sincronizar (mock fijo).
const syncStatusPendingCount = 14;

/// Cantidad de registros ya procesados dentro de la sincronización en curso.
const syncStatusInProgressCount = 6;

/// Descripción mock de la conexión durante la sincronización.
const syncStatusConnectionLabel = 'Conexión 3G · velocidad lenta';

/// Estado de una fila de la cola de operaciones.
enum SyncQueueState {
  /// Operación enviándose en este momento.
  syncing,

  /// Operación esperando su turno para sincronizarse.
  pending,

  /// Operación que falló al sincronizar.
  error,

  /// Operación ya sincronizada con éxito.
  ok,
}

/// Una fila mock de la cola de operaciones de sincronización.
class SyncQueueEntryMock {
  /// Crea una entrada mock de la cola.
  const SyncQueueEntryMock({
    required this.state,
    required this.operationType,
    required this.detail,
    required this.time,
    this.errorMessage,
  });

  /// Estado actual de la operación.
  final SyncQueueState state;

  /// Tipo de operación (pesaje, vacunación, movimiento, etc.).
  final String operationType;

  /// Detalle corto de la operación (caravana, cantidad de animales, etc.).
  final String detail;

  /// Hora de la operación, en formato `HH:mm:ss`.
  final String time;

  /// Mensaje de error, sólo presente cuando `state` es `error`.
  final String? errorMessage;
}

/// Cola de operaciones mock, en el mismo orden que el diseño de referencia.
const syncQueueEntriesMock = [
  SyncQueueEntryMock(
    state: SyncQueueState.syncing,
    operationType: 'Pesaje',
    detail: '003 1284',
    time: '11:42:18',
  ),
  SyncQueueEntryMock(
    state: SyncQueueState.pending,
    operationType: 'Vacunación · aftosa',
    detail: '6 animales',
    time: '11:41:30',
  ),
  SyncQueueEntryMock(
    state: SyncQueueState.pending,
    operationType: 'Alta de animal',
    detail: '003 1295',
    time: '11:39:02',
  ),
  SyncQueueEntryMock(
    state: SyncQueueState.error,
    operationType: 'Movimiento',
    detail: 'La Loma → El Bajo · 24 cab',
    time: '11:32:55',
    errorMessage: 'Conflicto con servidor',
  ),
  SyncQueueEntryMock(
    state: SyncQueueState.ok,
    operationType: 'Tratamiento · ivermectina',
    detail: '14 animales',
    time: '11:28:11',
  ),
  SyncQueueEntryMock(
    state: SyncQueueState.ok,
    operationType: 'Pesaje',
    detail: '003 1287',
    time: '11:27:48',
  ),
  SyncQueueEntryMock(
    state: SyncQueueState.ok,
    operationType: 'Pesaje',
    detail: '003 1290',
    time: '11:27:24',
  ),
];

/// Un conflicto last-write-wins mock entre un cambio local y el del servidor.
class SyncConflictMock {
  /// Crea un conflicto mock.
  const SyncConflictMock({
    required this.title,
    required this.description,
    required this.localTimestampLabel,
    required this.localValue,
    required this.serverAuthorTimestampLabel,
    required this.serverValue,
  });

  /// Título corto del conflicto.
  final String title;

  /// Descripción de qué pasó en el servidor.
  final String description;

  /// Etiqueta "local · fecha hora" del cambio propio.
  final String localTimestampLabel;

  /// Valor del cambio local.
  final String localValue;

  /// Etiqueta "autor · fecha hora" del cambio en el servidor.
  final String serverAuthorTimestampLabel;

  /// Valor del cambio en el servidor.
  final String serverValue;
}

/// Conflicto mock único mostrado en la pantalla de sincronización.
const syncConflictsMock = [
  SyncConflictMock(
    title: 'Movimiento de potrero · animal 003 1284',
    description: 'En el servidor otro usuario ya movió este animal el 14/05 a las 18:12.',
    localTimestampLabel: 'local · 15/05 11:32',
    localValue: 'La Loma → El Bajo',
    serverAuthorTimestampLabel: 'Cecilia · 14/05 18:12',
    serverValue: 'La Loma → San José',
  ),
];
