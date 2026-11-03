import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

/// Textos centralizados de la pantalla de estado de sincronización.
abstract final class SyncStatusStrings {
  /// Título de la pantalla.
  static const title = 'Sincronización';

  /// Tooltip del botón de sincronización manual.
  static const refreshTooltip = 'Sincronizar ahora';

  /// Subtítulo del header con la cantidad de pendientes.
  static String pendingSubtitle(int pending) => switch (pending) {
    0 => 'Todo sincronizado',
    1 => '1 registro pendiente',
    _ => '$pending registros pendientes',
  };

  /// Subtítulo mientras se lee la cola por primera vez.
  static const loadingSubtitle = 'Revisando registros pendientes…';

  /// Título del banner mientras hay registros enviándose.
  static String sendingBannerTitle(int pending) =>
      pending == 1 ? 'Enviando 1 registro…' : 'Enviando $pending registros…';

  /// Título del banner con pendientes y conexión, pero nada en curso.
  static String waitingBannerTitle(int pending) =>
      pending == 1 ? '1 registro esperando su turno' : '$pending registros esperando su turno';

  /// Título del banner sin conexión y con pendientes.
  static String offlineBannerTitle(int pending) =>
      pending == 1 ? '1 registro guardado en el teléfono' : '$pending registros guardados en el teléfono';

  /// Detalle del banner cuando no hay conexión.
  static const offlineBannerDetail = 'Se envían solos cuando vuelva la señal.';

  /// Detalle del banner cuando hay conexión.
  static const onlineBannerDetail = 'Se envían en orden, uno por vez.';

  /// Título del banner sin pendientes.
  static const emptyBannerTitle = 'Todo sincronizado';

  /// Detalle del banner sin pendientes.
  static const emptyBannerDetail = 'Lo que registres sin señal va a aparecer acá hasta que llegue al servidor.';

  /// Título de la sección de cola de operaciones.
  static const queueSectionTitle = 'Cola de operaciones';

  /// Mensaje cuando no se pudo leer la cola local.
  static const readError = 'No pudimos leer la cola. Tus registros siguen guardados en el teléfono.';

  /// Mensaje cuando la sincronización manual falló.
  static const manualSyncFailed = 'No se pudo sincronizar ahora. Los registros siguen guardados y se reintentan solos.';

  /// Nombre de cada tipo de operación.
  static String operationKind(SyncOperationKind kind) => switch (kind) {
    SyncOperationKind.animalRegistration => 'Alta de animal',
    SyncOperationKind.animalUpdate => 'Cambio en un animal',
    SyncOperationKind.weighing => 'Pesaje',
    SyncOperationKind.lotMovement => 'Movimiento entre lotes',
    SyncOperationKind.lot => 'Lote',
    SyncOperationKind.operatingExpense => 'Egreso operativo',
    SyncOperationKind.operatingExpenseCategory => 'Categoría de egreso',
    SyncOperationKind.other => 'Otro registro',
  };

  /// Estado de cada operación.
  static String operationState(SyncQueueOperation operation) => switch (operation.state) {
    SyncOperationState.waiting => 'En espera',
    SyncOperationState.sending => 'Enviando…',
    SyncOperationState.retrying =>
      'Reintentando · ${operation.attempts - 1} ${operation.attempts == 2 ? 'fallo' : 'fallos'}',
  };
}
