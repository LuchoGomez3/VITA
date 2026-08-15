/// Textos centralizados del flujo de sanidad.
abstract final class HealthStrings {
  /// Título del establecimiento mostrado en el header.
  static const establishmentTitle = 'La Sirena';

  /// Título de la pantalla.
  static const title = 'Sanidad';

  /// Tab de campañas de vacunación.
  static const vaccinationsTab = 'Vacunaciones';

  /// Tab de tratamientos.
  static const treatmentsTab = 'Tratamientos';

  /// Tab de alertas.
  static const alertsTab = 'Alertas';

  /// Título de la sección de campañas activas.
  static String activeCampaignsTitle(int count) => 'Campañas activas · $count';

  /// Título de la sección de vacunaciones programadas.
  static const scheduledSectionTitle = 'Programadas · próx. 30 días';

  /// Estado de una vacunación programada.
  static const scheduledPendingLabel = 'pendiente';

  /// Link de una campaña activa hacia Aplicar vacunación.
  static const applyLink = 'Aplicar →';

  /// Sufijo de cantidad de animales.
  static const animalCountSuffix = 'animales';

  /// Botón flotante para aplicar una vacunación.
  static const applyFab = '+ Aplicar';

  /// Título de la sección de tratamientos en curso.
  static String treatmentsInProgressTitle(int count) => 'Tratamientos en curso · $count';

  /// Título de la sección de historial de tratamientos.
  static const treatmentHistoryTitle = 'Historial · últimos 90 días';

  /// Etiqueta de carencia activa dentro de un tratamiento en curso.
  static const withdrawalActiveLabel = 'Carencia activa';

  /// Título de la pantalla de Aplicar vacunación.
  static const applyVaccinationTitle = 'Aplicar vacunación';

  /// Cierre de la pantalla de Aplicar vacunación.
  static const applyVaccinationCloseTooltip = 'Cerrar';

  /// Título del bloque de animales seleccionados.
  static String selectedAnimalsTitle(int count) => '$count seleccionados';

  /// Link para limpiar la selección de animales.
  static const clearSelectionLink = 'Limpiar';

  /// Botón para leer otra caravana por Bluetooth.
  static const readAnotherTagButton = 'Leer otra caravana';

  /// Título del bloque de producto.
  static const productSectionTitle = 'Producto';

  /// Campo de producto/vacuna.
  static const productFieldLabel = 'Producto / vacuna';

  /// Campo de lote.
  static const batchFieldLabel = 'Lote';

  /// Campo de dosis, en mililitros.
  static const doseFieldLabel = 'Dosis (ml)';

  /// Campo de fecha de aplicación.
  static const applicationDateFieldLabel = 'Fecha de aplicación';

  /// Mensaje de carencia mostrado en el callout, con los días indicados.
  static String withdrawalCallout(int days, String message) => 'Carencia: $days días. $message';

  /// CTA fijo para registrar la aplicación.
  static const registerApplicationCta = 'Registrar aplicación';

  /// Toast de confirmación tras registrar una aplicación.
  static const applicationRegisteredToast = 'Aplicación registrada';
}
