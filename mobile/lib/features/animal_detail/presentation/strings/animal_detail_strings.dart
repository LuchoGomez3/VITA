import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';

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

  /// Acción para registrar la muerte, con confirmación y posibilidad de deshacer.
  static const deathAction = 'Baja por muerte';

  /// Abre la asignación o traslado a otro lote.
  static const changeLotAction = 'Cambiar de lote';

  /// Acceso a la futura creación de observaciones.
  static const newObservationAction = 'Nueva entrada';

  /// Textos del ensayo de confirmación; no se registra una baja real.
  static const deathConfirmationTitle = '¿Dar de baja por muerte?';

  /// Explica la baja y la posibilidad de deshacer sin borrar el historial.
  static const deathConfirmationMessage =
      'El animal quedará dado de baja por muerte. Su historial se conserva y podrás deshacer la baja si fue un error.';

  /// Confirma el guardado local de la baja mientras se sincroniza.
  static const deathSavedMessage = 'Baja por muerte guardada en el dispositivo.';

  /// Cierra la confirmación sin continuar la vista previa.
  static const cancelAction = 'Cancelar';

  /// Continúa la vista previa de la confirmación.
  static const confirmAction = 'Confirmar';

  /// Revierte la última baja guardada desde esta ficha.
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

  /// Primer movimiento de un animal que todavía no tenía lote.
  static const initialLotAssignmentTitle = 'Asignación a lote';

  /// Cambio de ubicación con origen y destino registrados.
  static const lotTransferTitle = 'Traslado de lote';

  /// Texto utilizado cuando el origen no estaba asignado.
  static const unassignedLotLabel = 'Sin lote asignado';

  /// Conserva el motivo y distingue un hecho confirmado de una escritura local.
  static String lotMovementEventDescription(AnimalLotMovementEvent event) {
    final status = switch (event.syncStatus) {
      AnimalSyncStatus.pending => 'Pendiente de sincronización',
      AnimalSyncStatus.synchronized => 'Confirmado por el servidor',
      AnimalSyncStatus.rejected when event.syncErrorCode?.startsWith('released_local_destination:') ?? false =>
        'Destino no sincronizado. Intento rechazado; animales devueltos al origen.',
      AnimalSyncStatus.rejected =>
        'Rechazado por el servidor${event.syncErrorCode == null ? '' : ' (${event.syncErrorCode})'}',
    };
    return '${event.sourceName ?? unassignedLotLabel} → ${event.destinationName}\n${event.reason}\n$status';
  }

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

  /// Acción de confirmación de formularios.
  static const saveAction = 'Guardar';

  /// Campo para una nueva pesada manual.
  static const weightInputLabel = 'Peso (kg)';

  /// Campo de texto de la nueva entrada.
  static const observationInputLabel = 'Observación';

  /// Validación de peso vacío, no finito o no positivo.
  static const invalidWeightError = 'Ingresá un peso válido mayor a cero.';

  /// Validación de notas vacías.
  static const emptyObservationError = 'Escribí una observación.';

  /// Selector sin categorías compatibles en el catálogo local.
  static const noCompatibleCategories =
      'No hay categorías compatibles disponibles. Actualizá la ficha con conexión para descargar el catálogo.';

  /// Explica por qué no se puede elegir preñada o vacía todavía.
  static const reproductiveCategoryHelp =
      'La categoría actual no permite registrar preñez. Primero elegí una categoría compatible.';

  /// Condición reproductiva no aplicable.
  static const notApplicable = 'No corresponde';

  /// Etiqueta de la nueva fila de condición reproductiva.
  static const reproductiveStatusLabel = 'Condición reproductiva';

  /// Etiqueta del estado de negocio del animal.
  static const animalStatusLabel = 'Estado';

  /// Confirma un guardado local sin prometer aceptación inmediata del backend.
  static const changeSavedMessage = 'Cambio guardado en el dispositivo. Se sincronizará con el backend.';

  /// Confirma que se restauró el estado anterior de una baja.
  static const deathUndoneMessage = 'Se deshizo la baja por muerte.';

  /// Estado de nota aún sin confirmar remotamente.
  static const String notePending = pendingSyncStatus;

  /// Estado de nota que necesita corrección por rechazo del backend.
  static const noteRejected = 'No se pudo sincronizar esta entrada';

  /// Traduce códigos de condición a etiquetas del selector y de la ficha.
  static String reproductionLabel(AnimalReproductiveStatus? status) => switch (status) {
    null => notApplicable,
    AnimalReproductiveStatus.undetermined => 'Sin determinar',
    AnimalReproductiveStatus.empty => 'Vacía',
    AnimalReproductiveStatus.pregnant => 'Preñada',
  };

  /// Expone los cuatro estados reales, separados del estado de sincronización.
  static String statusLabel(AnimalStatus status) => switch (status) {
    AnimalStatus.active => 'Activo',
    AnimalStatus.sold => 'Vendido',
    AnimalStatus.dead => 'Muerto',
    AnimalStatus.inactive => 'Baja',
  };

  /// Traduce errores estructurados de dominio sin mostrar mensajes técnicos.
  static String editError(DomainException error) => switch (error.reason) {
    AnimalDetailEditFailure.invalidWeight => invalidWeightError,
    AnimalDetailEditFailure.emptyObservation => emptyObservationError,
    AnimalDetailEditFailure.inactiveAnimal => 'El animal no está activo para esta operación.',
    AnimalDetailEditFailure.incompatibleCategory => noCompatibleCategories,
    AnimalDetailEditFailure.reproductionNotAllowed => reproductiveCategoryHelp,
    AnimalDetailEditFailure.animalNotFound => 'No se encontró el animal en este dispositivo.',
    AnimalDetailEditFailure.staleUndo => 'La baja ya cambió. Actualizá la ficha antes de corregirla.',
    AnimalDetailEditFailure.saveFailed => 'No se pudo guardar el cambio. Intentá nuevamente.',
    _ => error.message,
  };
}
