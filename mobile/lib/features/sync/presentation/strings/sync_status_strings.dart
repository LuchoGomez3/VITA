/// Textos centralizados de la pantalla de estado de sincronización.
abstract final class SyncStatusStrings {
  /// Título de la pantalla.
  static const title = 'Sincronización';

  /// Tooltip del botón de refresh manual.
  static const refreshTooltip = 'Sincronizar ahora';

  /// Subtítulo con la última sincronización y la cantidad de pendientes.
  static String lastSyncSubtitle(String lastSync, int pending) => 'Última: $lastSync · $pending pendientes';

  /// Título del banner de progreso mientras sincroniza.
  static String progressBannerTitle(int total) => 'Sincronizando $total registros…';

  /// Contador "hechos / total" del banner de progreso.
  static String progressCounter(int done, int total) => '$done / $total';

  /// Título de la sección de cola de operaciones.
  static const queueSectionTitle = 'Cola de operaciones';

  /// Título de la sección de conflictos, con la cantidad.
  static String conflictsSectionTitle(int count) => 'Conflictos · $count';

  /// Etiqueta de la chip de estrategia de resolución.
  static const lastWriteWinsChipLabel = 'Last-write-wins';

  /// Título del bloque con el cambio propio.
  static String localChangeLabel(String timestamp) => 'Tu cambio ($timestamp)';

  /// Título del bloque con el cambio del servidor.
  static String serverChangeLabel(String authorTimestamp) => 'En servidor ($authorTimestamp)';

  /// Botón para quedarse con el valor del servidor.
  static const keepServerButtonLabel = 'Mantener servidor';

  /// Botón para aplicar el valor propio por sobre el del servidor.
  static const applyMineButtonLabel = 'Aplicar el mío';

  /// Mensaje mostrado cuando una acción todavía no está implementada de
  /// verdad (refresh manual y resolución de conflictos).
  static const outOfScopeMessage = 'Fuera de alcance de esta iniciativa';
}
