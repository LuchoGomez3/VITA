/// Textos centralizados del flujo de pesaje en manga.
abstract final class WeighingStrings {
  /// Título de la pantalla (usado solo como referencia semántica, el header
  /// visual no muestra un título de app bar tradicional).
  static const title = 'Pesaje en manga';

  /// Tab de captura por balanza Bluetooth.
  static const bluetoothTab = 'Bluetooth';

  /// Tab de captura manual.
  static const manualTab = 'Manual';

  /// Tab de captura por foto, deshabilitada en esta iniciativa.
  static const photoTab = 'Por foto';

  /// Etiqueta mostrada sobre la tab deshabilitada de foto.
  static const photoTabComingSoon = 'Próximamente';

  /// Sufijo de unidad mostrado junto al peso.
  static const weightUnit = 'kg';

  /// Prefijo del chip de GPD respecto del pesaje anterior.
  static const gpdLabel = 'GPD vs. anterior:';

  /// Sufijo de unidad del GPD.
  static const gpdUnit = 'kg/día';

  /// Sufijo de estado de la balanza cuando está conectada y estable.
  static const scaleStableSuffix = 'estable';

  /// CTA fijo para confirmar el pesaje capturado.
  static const saveCta = 'Guardar pesaje';

  /// Título del toast de confirmación tras guardar un pesaje.
  static const savedToastTitle = 'Pesaje guardado';

  /// Subtítulo del toast de confirmación tras guardar un pesaje.
  static String savedToastSubtitle(String gpdDelta) =>
      'GPD vs. anterior: $gpdDelta kg/día · Avanzando al siguiente animal…';

  /// Separador de progreso de lote (ej. `'8 / 142'`).
  static String batchProgress(int current, int total) => '$current / $total';

  /// Botón de retroceso/cierre del flujo.
  static const closeTooltip = 'Cerrar';

  /// Placeholder mostrado cuando todavía no se ingresó un peso manual.
  static const manualWeightPlaceholder = '0';

  /// Tecla de borrado del numpad manual.
  static const numpadBackspaceLabel = '⌫';

  /// Separador decimal usado en el numpad manual (formato es-AR).
  static const numpadDecimalSeparator = ',';
}
