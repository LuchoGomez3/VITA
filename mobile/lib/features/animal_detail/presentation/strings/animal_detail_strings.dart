/// Textos de la pantalla de detalle de animal.
class AnimalDetailStrings {
  const AnimalDetailStrings._();

  /// El animal deja de estar disponible localmente para la ficha abierta.
  static const animalUnavailable = 'Este animal ya no está disponible en el establecimiento.';

  /// Titulo del app bar.
  static const pageTitle = 'Detalle de animal';

  /// Identifica la fotografía tanto visualmente como para lectores de pantalla.
  static const animalPhotoLabel = 'Foto del animal';

  /// Etiqueta del identificador principal.
  static const animalIdLabel = 'Caravana / ID';

  /// Etiqueta de ubicacion actual.
  static const currentLocationLabel = 'Ubicación actual';

  /// Estado productivo activo.
  static const productiveStatusActive = 'Activo';

  /// Estado productivo vendido.
  static const productiveStatusSold = 'Vendido';

  /// Estado productivo muerto.
  static const productiveStatusDead = 'Muerto';

  /// Estado productivo dado de baja.
  static const productiveStatusRemoved = 'Dado de baja';

  /// Estado productivo que esta version no reconoce.
  static const productiveStatusUnknown = 'Estado desconocido';

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

  /// Abre el formulario para agregar una nota.
  static const addObservation = 'Agregar observación';

  /// Texto del formulario de observaciones.
  static const observationHint = 'Escribí una observación';

  /// Confirma una nota nueva.
  static const saveObservation = 'Guardar observación';

  /// Error de almacenamiento de una nota.
  static const observationSaveError = 'No se pudo guardar la observación.';

  /// Error de lectura del historial de notas.
  static const observationReadError = 'No se pudieron leer las observaciones.';

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
  static const rejectedSyncTitle = 'No se pudo sincronizar la operación';

  /// Mensaje generico para cualquier rechazo funcional del backend.
  static const rejectedSyncMessage = 'La operación fue rechazada por el servidor. Intentá sincronizarla nuevamente.';

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

  /// Acceso a la cámara desde el espacio vacío de la foto.
  static const takePhoto = 'Sacar foto';

  /// Error recuperable al abrir la cámara o guardar la captura.
  static const takePhotoError = 'No se pudo sacar o guardar la foto. Revisá el permiso de cámara y volvé a intentar.';

  /// Pestaña que todavía no está desarrollada.
  static const comingSoonTitle = 'Próximamente';

  /// Título del árbol genealógico.
  static const genealogyTreeTitle = 'Árbol genealógico · 3 generaciones';

  /// Error de lectura de los datos locales de parentesco.
  static const genealogyLoadError = 'No se pudo cargar la genealogía del animal.';

  /// Sección de padre y madre.
  static const genealogyParentsSection = 'Progenitores';

  /// Sección de los abuelos.
  static const genealogyGrandparentsSection = 'Abuelos';

  /// Sección de los hijos del animal.
  static String genealogyOffspringSection(int count) => 'Crías · $count';

  /// Ayuda al pie del árbol.
  static const genealogyTapHint = 'Tocá cualquier progenitor para abrir su ficha.';

  /// Nodo del animal de la ficha.
  static String genealogyCurrent(String breed) => breed.isEmpty ? 'Actual' : 'Actual · $breed';

  /// Rol del padre.
  static const genealogyFather = 'Padre';

  /// Rol de la madre.
  static const genealogyMother = 'Madre';

  /// Rol del abuelo paterno.
  static const genealogyPaternalGrandfather = 'Abuelo paterno';

  /// Rol de la abuela paterna.
  static const genealogyPaternalGrandmother = 'Abuela paterna';

  /// Rol del abuelo materno.
  static const genealogyMaternalGrandfather = 'Abuelo materno';

  /// Rol de la abuela materna.
  static const genealogyMaternalGrandmother = 'Abuela materna';

  /// Etiqueta de un nodo con datos: "Madre · Aberdeen Angus".
  static String genealogyNode(String role, String detail) => detail.isEmpty ? role : '$role · $detail';

  /// Etiqueta de un nodo sin datos.
  static String genealogyMissing(String role) => '$role · sin datos';

  /// Cuando no hay ningún dato de padres ni crías.
  static const genealogyEmpty =
      'No hay madre ni padre cargados. Se asignan al dar de alta el animal, entre los animales del mismo establecimiento.';

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

  /// Título del historial en la ficha.
  static String historyTitle(int count) =>
      count == 1 ? 'Historial de potreros · 1 movim.' : 'Historial de potreros · $count movim.';

  /// Historial vacío.
  static const historyEmpty = 'Este animal todavía no tiene movimientos entre potreros.';

  /// Error del historial.
  static const historyError = 'No se pudo leer el historial de movimientos.';

  /// Potrero actual en la primera fila del historial.
  static const currentLot = '(actual)';

  /// Origen de la primera asignación.
  static const noOrigin = '—';

  /// Primer lote asignado al registrar el animal.
  static const initialLotAssignment = 'Asignación inicial';

  /// Lote del historial cuyo nombre todavía no está disponible localmente.
  static const unknownMovementLot = 'Potrero sin nombre';

  /// Movimiento que todavía no llegó al servidor.
  static const pendingSync = 'Pendiente de sincronizar';

  /// Un rechazo funcional no se reenvía como una operación pendiente.
  static const movementRejected = 'Movimiento rechazado por el servidor';

  /// Recuperación después de un rechazo del traslado.
  static const movementRejectionHint = 'Revisá el potrero actual antes de registrar un nuevo movimiento.';

  /// Confirmación al volver a la ficha.
  static String moved(int count, String destination) =>
      count == 1 ? 'Se movió 1 animal a $destination.' : 'Se movieron $count animales a $destination.';

  /// La confirmación describe los destinos guardados aunque el animal de la
  /// ficha haya sido quitado de la selección o falle la recarga del detalle.
  static String movementConfirmation(int count, Map<String, String> destinations) {
    if (destinations.length == 1) return moved(count, destinations.values.single);
    if (destinations.isEmpty) return count == 1 ? 'Se movió 1 animal.' : 'Se movieron $count animales.';
    return 'Se movieron $count animales a ${destinations.length} potreros.';
  }

  /// Aclaración offline de la confirmación.
  static const savedOffline = 'Queda guardado en el celular y se sincroniza con señal.';

  /// Pestaña de alimentación.
  static const feedingTab = 'Alimentación';

  /// Confirmación al volver del registro.
  static const feedingSaved = 'Alimentación guardada en el celular. Se sincroniza con señal.';

  /// Botón para registrar alimentación.
  static const newFeedingTooltip = 'Registrar alimentación';

  /// Encabezado del resumen.
  static const feedingNow = 'Ahora';

  /// Encabezado del historial.
  static const feedingHistoryTitle = 'Historial';

  /// Sección de suplementos vigentes.
  static const ongoingSupplementsTitle = 'Suplementación en curso';

  /// Sin potrero actual.
  static const noCurrentGrazing = 'Sin potrero asignado';

  /// Chip del pastoreo.
  static const grazingChip = 'Pastoreo';

  /// Chip del suplemento.
  static const supplementChip = 'Suplemento';

  /// Chip de la dieta.
  static const dietChip = 'Dieta';

  /// Chip de tramo inferido.
  static const estimatedChip = 'Estimado';

  /// Tramo sin recurso cargado.
  static const noForageRecorded = 'Recurso sin registrar';

  /// Chip de rechazo.
  static const rejectedChip = 'Rechazado';

  /// Explica el chip "Estimado" cuando el animal no tiene movimientos.
  static const estimatedNoMovements =
      'Estimado: no hay movimientos de este animal. Se asume que está en su potrero actual desde que se cargó en la app.';

  /// Explica el chip "Estimado" antes del primer movimiento.
  static const estimatedBeforeFirstMovement =
      'Estimado: antes de su primer movimiento se asume el potrero de origen desde que se cargó en la app.';

  /// Explica el chip "Estimado" cuando dos movimientos no encadenan.
  static const estimatedBrokenChain =
      'Estimado: falta un movimiento entre dos registrados (salió de un potrero distinto al que había llegado).';

  /// Explica el chip "Estimado" cuando el potrero se editó desde la ficha.
  static const estimatedLotEdited =
      'Estimado: el potrero se cambió desde la ficha, sin registrar un movimiento. El corte se toma de esa edición.';

  /// Título del estado vacío.
  static const feedingEmptyTitle = 'Todavía no hay alimentación registrada';

  /// Mensaje del estado vacío.
  static const feedingEmptyMessage =
      'El pastoreo se arma solo con los movimientos del animal y el recurso de cada potrero. '
      'Los suplementos y dietas se cargan con el botón +.';

  /// Atajo para cargar el recurso del potrero actual.
  static const loadLotForageCta = 'Cargar recurso del potrero';

  /// Error de lectura.
  static const feedingError = 'No se pudo leer la alimentación guardada.';

  /// Recurso y potrero de un tramo.
  static String grazingTitle(String resource, String lotName) => lotName.isEmpty ? resource : '$resource · $lotName';

  /// Rango de fechas.
  static String feedingRange(String from, String? to) => '$from → ${to ?? 'hoy'}';

  /// Duración en días.
  static String feedingDays(int days) => days == 1 ? '1 día' : '$days días';

  /// "desde dd/mm/aaaa".
  static String since(String date) => 'desde $date';

  /// Lugar de un suplemento.
  static String feedingPlace(String? lotName) => lotName ?? 'Corral o manga';
}
