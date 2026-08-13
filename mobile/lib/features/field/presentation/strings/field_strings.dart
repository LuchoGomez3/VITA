/// Textos centralizados del flujo de campo y potreros.
abstract final class FieldStrings {
  /// Título del establecimiento mostrado en el header.
  static const establishmentTitle = 'La Sirena';

  /// Título de la pantalla de mapa y de lista.
  static const title = 'Campo';

  /// Cantidad de registros de sincronización pendientes (mock fijo).
  static const pendingSyncCount = 14;

  /// Label del KPI de cantidad de potreros.
  static const paddocksKpiLabel = 'POTREROS';

  /// Label del KPI de cabezas totales.
  static const headCountKpiLabel = 'CABEZAS';

  /// Título de la leyenda de densidad del mapa.
  static const densityLegendTitle = 'DENSIDAD';

  /// Etiqueta de densidad baja.
  static const densityLow = 'Baja';

  /// Etiqueta de densidad media.
  static const densityMedium = 'Media';

  /// Etiqueta de densidad alta.
  static const densityHigh = 'Alta';

  /// Etiqueta de densidad nula (potrero libre).
  static const densityNone = 'Libre';

  /// Tab del toggle que muestra el mapa.
  static const mapTab = 'Mapa';

  /// Tab del toggle que muestra la lista.
  static const listTab = 'Lista';

  /// Chip con el total de hectáreas en la barra de filtros de la lista.
  static String totalHectaresChip(String hectares) => '$hectares ha totales';

  /// Chip con la cantidad de potreros en la barra de filtros de la lista.
  static String paddockCountChip(int count) => '$count potreros';

  /// Sufijo de hectáreas para una card de la lista.
  static const hectaresSuffix = 'ha';

  /// Prefijo de cabezas para una card de la lista.
  static const headCountSuffix = 'cab';

  /// Sección "Forraje y servicios" del detalle.
  static const forageSectionTitle = 'Forraje y servicios';

  /// Fila de recurso forrajero.
  static const forageResourceLabel = 'Recurso forrajero';

  /// Fila de aguada.
  static const waterSourceLabel = 'Aguada';

  /// Fila de última rotación.
  static const lastRotationLabel = 'Última rotación';

  /// Valor mock de la aguada del potrero de ejemplo.
  static const waterSourceValue = 'Tanque australiano · 60 m³';

  /// Valor mock de la última rotación del potrero de ejemplo.
  static const lastRotationValue = 'hace 8 días';

  /// Título de la sección de animales en el potrero.
  static String animalsSectionTitle(int headCount) => 'Animales en potrero · $headCount';

  /// Link de la sección de animales (sin pantalla destino todavía).
  static const viewAnimalsLink = 'Ver lista →';

  /// Título de la sección de historial de ocupación.
  static const occupationHistoryTitle = 'Historial de ocupación';

  /// Título del KPI de cabezas en el detalle.
  static const headCountDetailLabel = 'Cabezas';

  /// Título del KPI de superficie en el detalle.
  static const surfaceDetailLabel = 'Superficie';

  /// Título del KPI de densidad en el detalle.
  static const densityDetailLabel = 'Densidad';

  /// Sufijo del KPI de densidad (cabezas por hectárea).
  static const densityUnit = 'cab/ha';

  /// CTA fijo al pie del detalle (sin flujo destino todavía).
  static const moveAnimalsCta = 'Mover a otro potrero';
}
