/// Textos de la pantalla de detalle de animal.
class AnimalDetailStrings {
  const AnimalDetailStrings._();

  /// Titulo del app bar.
  static const pageTitle = 'Detalle de animal';

  /// Identifica la fotografía tanto visualmente como para lectores de pantalla.
  static const animalPhotoLabel = 'Foto del animal';

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

  /// Acciones visuales pendientes de conectar a sus casos de uso.
  static const enterWeightAction = 'Ingresar peso';
  /// Acceso a la futura edición de categoría.
  static const changeCategoryAction = 'Cambiar categoría';
  /// Acceso al futuro cambio de estado reproductivo en hembras.
  static const changePregnancyAction = 'Cambiar preñez';
  /// Acceso a la vista previa de baja por muerte.
  static const deathAction = 'Baja por muerte';
  /// Acceso a la futura creación de observaciones.
  static const newObservationAction = 'Nueva entrada';

  /// Textos del ensayo de confirmación; no se registra una baja real.
  static const deathConfirmationTitle = '¿Dar de baja por muerte?';
  /// Explica la confirmación y el carácter visual de la maqueta.
  static const deathConfirmationMessage =
      'Esta acción dará de baja al animal y permitirá deshacerla. Por ahora es una vista previa y no modifica datos.';
  /// Avisa que confirmar no afectó ningún registro.
  static const deathPreviewMessage = 'Vista previa de baja por muerte. No se modificaron datos.';
  /// Cierra la confirmación sin continuar la vista previa.
  static const cancelAction = 'Cancelar';
  /// Continúa la vista previa de la confirmación.
  static const confirmAction = 'Confirmar';
  /// Descarta el aviso visual sin una operación de reversión real.
  static const undoAction = 'Deshacer';

  /// Metodo de pesaje manual.
  static const manualWeighingMethod = 'Manual';

  /// Metodo de pesaje por balanza bluetooth.
  static const bluetoothWeighingMethod = 'Balanza Bluetooth';

  /// Metodo de pesaje por IA.
  static const aiWeighingMethod = 'Estimación por IA';

  /// Titulo del grafico de peso.
  static const weightChartTitle = 'Evolución de Peso';

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

  /// Etiqueta de ultima lectura.
  static const lastReadingLabel = 'Última lectura:';

  /// Mensaje de error de carga.
  static const loadError = 'Error al cargar la información del animal.';

  /// Valor mostrado cuando el backend/cache aun no tiene un dato.
  static const noDataValue = 'Sin dato';
}
