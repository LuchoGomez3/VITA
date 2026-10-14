/// Textos de la pantalla de detalle de animal.
class AnimalDetailStrings {
  const AnimalDetailStrings._();

  /// Titulo del app bar.
  static const pageTitle = 'Detalle de animal';

  /// Etiqueta del identificador principal.
  static const animalIdLabel = 'Caravana / ID';

  /// Etiqueta de ubicacion actual.
  static const currentLocationLabel = 'Ubicación actual';

  /// Etiqueta de raza.
  static const breedLabel = 'Raza';

  /// Etiqueta de sexo.
  static const sexLabel = 'Sexo';

  /// Sexo macho.
  static const sexMale = 'Macho';

  /// Sexo hembra.
  static const sexFemale = 'Hembra';

  /// Etiqueta de categoria.
  static const categoryLabel = 'Categoría';

  /// Etiqueta de pelaje.
  static const coatLabel = 'Pelaje';

  /// Etiqueta de fecha de nacimiento.
  static const birthDateLabel = 'Fecha de Nacimiento';

  /// Etiqueta de edad.
  static const ageLabel = 'Edad';

  /// Sufijo de meses.
  static const monthsSuffix = 'meses';

  /// Sufijo de años.
  static const yearsSuffix = 'años';

  /// Etiqueta de ultimo peso.
  static const lastWeightLabel = 'Último peso';

  /// Etiqueta de fuente del ultimo peso.
  static const lastWeightSourceLabel = 'Fuente último peso';

  /// Etiqueta de observaciones.
  static const observationsLabel = 'Observaciones';

  /// Metodo de pesaje manual.
  static const manualWeighingMethod = 'Manual';

  /// Metodo de pesaje por balanza bluetooth.
  static const bluetoothWeighingMethod = 'Balanza Bluetooth';

  /// Metodo de pesaje por IA.
  static const aiWeighingMethod = 'Estimación por IA';

  /// Titulo del grafico de peso.
  static const weightChartTitle = 'Evolución del peso';

  /// Mensaje mostrado cuando el animal todavia no tiene pesajes registrados.
  static const noWeightHistory = 'Todavía no hay pesajes registrados.';

  /// Titulo del historial.
  static const eventHistoryTitle = 'Historial de Eventos';

  /// Titulo del evento de nacimiento.
  static const birthEventTitle = 'Nacimiento';

  /// Descripcion del evento de nacimiento.
  static const birthEventDescription = 'Fecha de nacimiento registrada.';

  /// Titulo usado para cada pesaje dentro del historial de eventos.
  static const weighingEventTitle = 'Pesaje';

  /// Construye el detalle visible de un pesaje con su peso y metodo de captura.
  static String weighingEventDescription({
    required String weight,
    required String method,
  }) => 'Peso registrado: $weight kg · Método: $method.';

  /// Estado pendiente de sincronizacion.
  static const pendingSyncStatus = 'Pendiente de sincronización';

  /// Estado sincronizado.
  static const synchronizedSyncStatus = 'Sincronizado con backend';

  /// Estado rechazado por backend.
  static const rejectedSyncStatus = 'Rechazado por backend';

  /// Titulo visible cuando backend rechazo la sincronizacion.
  static const rejectedSyncTitle = 'No se pudo sincronizar el animal';

  /// Mensaje generico para cualquier rechazo funcional del backend.
  static const rejectedSyncMessage = 'El alta fue rechazada por el servidor. Intentá sincronizarla nuevamente.';

  /// Accion para volver a encolar el alta rechazada.
  static const retrySync = 'Reintentar';

  /// Etiqueta de ultima lectura.
  static const lastReadingLabel = 'Última lectura:';

  /// Mensaje de error de carga.
  static const loadError = 'Error al cargar la información del animal.';

  /// Valor mostrado cuando el backend/cache aun no tiene un dato.
  static const noDataValue = 'Sin dato';

  /// Pestañas de la ficha (diseño "Ficha · General").
  static const generalTab = 'General';

  /// Pestaña de genealogía.
  static const genealogyTab = 'Genealogía';

  /// Pestaña de pesajes.
  static const weighingsTab = 'Pesajes';

  /// Pestaña de sanidad.
  static const healthTab = 'Sanidad';

  /// Pestaña de movimientos (abreviada como en el diseño).
  static const movementsTab = 'Movim.';

  /// Subtítulo de la cabecera: categoría y edad.
  static String headerSubtitle(String category, String age) =>
      [category, age].where((part) => part.isNotEmpty).join(' · ');

  /// Título de la sección de identificación.
  static const identificationSection = 'Identificación';

  /// Fila RFID.
  static const rfidLabel = 'RFID';

  /// Fila caravana visual.
  static const visualTagLabel = 'Caravana visual';

  /// Fila potrero actual.
  static const currentLotLabel = 'Potrero actual';

  /// Fila de edad calculada.
  static const calculatedAgeLabel = 'Edad calculada';

  /// Fila de fecha de nacimiento (diseño, en minúscula).
  static const birthDateRowLabel = 'Fecha nacimiento';

  /// Animal sin potrero asignado.
  static const noLot = 'Sin potrero';

  /// Placeholder de la foto del animal.
  static const photoPlaceholder = 'Sin foto del animal';

  /// Pestaña que todavía no está desarrollada.
  static const comingSoonTitle = 'Próximamente';

  /// Genealogía todavía no desarrollada.
  static const genealogyComingSoon = 'Acá vas a ver el árbol genealógico del animal: padres y abuelos.';

  /// Sanidad todavía no desarrollada.
  static const healthComingSoon = 'Acá vas a ver los tratamientos y vacunaciones del animal.';

  /// Título del histórico de pesajes.
  static String weighingHistoryTitle(int count) => 'Histórico · $count ${count == 1 ? 'pesaje' : 'pesajes'}';

  /// Fecha del último pesaje en la tarjeta de evolución.
  static String lastWeighing(String date) => 'Último: $date';

  /// Chip de ganancia diaria.
  static String dailyGain(String value) => 'GPD $value kg/día';

  /// Botón flotante para registrar un pesaje del animal.
  static const newWeighingTooltip = 'Registrar pesaje';

  /// Título de la hoja para elegir cómo pesar.
  static const weighingMethodSheetTitle = '¿Cómo querés pesarlo?';

  /// Opción de pesaje con balanza Bluetooth.
  static const weighingWithBluetooth = 'Balanza Bluetooth';

  /// Opción de pesaje manual.
  static const weighingManual = 'Carga manual';

  /// Opción de pesaje por foto.
  static const weighingWithPhoto = 'Foto (Pesaje IA)';

  /// Error al abrir la cámara.
  static const cameraError = 'No se pudo abrir la cámara. Revisá los permisos e intentá nuevamente.';
}
