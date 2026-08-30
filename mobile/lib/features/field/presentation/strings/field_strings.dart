import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';

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
  static const moveAnimalsCta = 'Mover animales';

  /// CTA para abrir la delimitación local de un lote.
  static const newLotCta = 'Nuevo lote';

  /// Título de la pantalla de delimitación.
  static const newLotTitle = 'Nuevo lote';

  /// Instrucción cuando todavía no hay vértices.
  static const lotEditorEmptyHint = 'Tocá el fondo para marcar el primer vértice';

  /// Instrucción durante el trazado abierto.
  static const lotEditorDrawingHint = 'Agregá al menos 3 puntos y cerrá el lote';

  /// Instrucción cuando el perímetro ya está cerrado.
  static const lotEditorClosedHint = 'Perímetro cerrado. Podés mover o eliminar vértices';

  /// Etiqueta para el campo de nombre.
  static const lotNameLabel = 'Nombre del lote';

  /// Ejemplo para el campo de nombre.
  static const lotNameHint = 'Ej. La Loma';

  /// Campo de superficie productiva declarada.
  static const surfaceHectaresLabel = 'Superficie (ha)';

  /// Ejemplo de superficie con un decimal.
  static const surfaceHectaresHint = 'Ej. 45,7';

  /// Aclara el redondeo persistido.
  static const surfaceHectaresHelper = 'Se guarda redondeada a 1 decimal.';

  /// Validación de superficie obligatoria.
  static const requiredSurfaceError = 'Ingresá una superficie mayor a 0.';

  /// Acción para cerrar el perímetro.
  static const closeLotBoundaryCta = 'Cerrar lote';

  /// Acción final de la Fase 1.
  static const confirmLotBoundaryCta = 'Confirmar delimitación';

  /// Continúa al segundo paso del alta.
  static const continueLotDetailsCta = 'Continuar';

  /// Regresa al editor conservando los datos.
  static const backToBoundaryCta = 'Volver a delimitación';

  /// Título del segundo paso.
  static const lotDetailsStepTitle = 'Datos del lote';

  /// Etiqueta del catálogo de forraje.
  static const forageResourceFieldLabel = 'Recurso forrajero';

  /// Opción vacía del catálogo.
  static const forageResourceHint = 'Seleccioná una opción (opcional)';

  /// Etiqueta para disponibilidad de agua.
  static const waterAvailabilityLabel = 'Disponibilidad de agua';

  /// Opción afirmativa de agua.
  static const waterAvailable = 'Tiene agua';

  /// Opción negativa de agua.
  static const waterUnavailable = 'Sin agua';

  /// Error cuando no se respondió la disponibilidad de agua.
  static const requiredWaterError = 'Indicá si el lote tiene agua disponible.';

  /// Etiqueta de estado operativo.
  static const lotStatusLabel = 'Estado inicial';

  /// Acción final del alta.
  static const saveLotCta = 'Guardar lote';

  /// Estado del botón mientras SQLite confirma la escritura.
  static const savingLotCta = 'Guardando…';

  /// Acción para deshacer.
  static const undoTooltip = 'Deshacer';

  /// Acción para rehacer.
  static const redoTooltip = 'Rehacer';

  /// Acción para eliminar el vértice seleccionado.
  static const deleteVertexTooltip = 'Eliminar vértice';

  /// Acción para limpiar el editor.
  static const clearBoundaryTooltip = 'Limpiar';

  /// Título de confirmación antes de eliminar el perímetro local.
  static const clearBoundaryDialogTitle = '¿Limpiar la delimitación?';

  /// Explicación de la acción destructiva local.
  static const clearBoundaryDialogMessage = 'Se eliminarán todos los vértices que marcaste.';

  /// Acción que conserva el perímetro actual.
  static const cancelClearBoundaryCta = 'Cancelar';

  /// Acción que confirma la limpieza del editor.
  static const confirmClearBoundaryCta = 'Limpiar';

  /// Indicador de norte en el viewport.
  static const northIndicator = 'N';

  /// Estado local mostrado mientras no existe persistencia.
  static const localDraftBadge = 'BORRADOR LOCAL';

  /// Mensaje al volver desde una delimitación válida.
  static const lotDraftValidatedMessage = 'Delimitación validada. El guardado se implementará en la próxima fase.';

  /// Etiqueta cuando todavía no existe contexto de establecimiento.
  static const noEstablishmentTitle = 'Sin establecimiento';

  /// Explica que el usuario necesita un establecimiento disponible offline.
  static const noEstablishmentMessage = 'No hay establecimientos disponibles en este dispositivo.';

  /// Respaldo al abrir el editor sin contexto de navegación.
  static const selectEstablishmentBeforeLot = 'Seleccioná un establecimiento para crear un lote.';

  /// Error de lectura local de la colección.
  static const localLotsLoadError = 'No se pudieron cargar los lotes guardados.';

  /// Acción genérica para reintentar una lectura local.
  static const retryCta = 'Reintentar';

  /// Etiqueta del selector multi-establecimiento.
  static const establishmentSelectorLabel = 'Establecimiento';

  /// Estado vacío del lienzo principal.
  static const noLocalLotsMessage = 'Todavía no registraste lotes en este establecimiento.';

  /// Distintivo explícito de persistencia local.
  static const savedOnDeviceBadge = 'GUARDADO EN EL DISPOSITIVO';

  /// Estado durable mostrado en el detalle.
  static const savedOnDeviceStatus = 'Disponible offline';

  /// Título de respaldo del detalle.
  static const lotDetailTitle = 'Detalle del lote';

  /// Acción para modificar datos alfanuméricos.
  static const editLotCta = 'Editar lote';

  /// Título del formulario de edición.
  static const editLotTitle = 'Editar datos del lote';

  /// Acción destructiva de borrado lógico.
  static const deleteLotCta = 'Eliminar lote';

  /// Título de confirmación del borrado.
  static const deleteLotDialogTitle = '¿Eliminar este lote?';

  /// Consecuencia del borrado lógico.
  static const deleteLotDialogMessage = 'El lote desaparecerá y su espacio podrá ser utilizado por otro.';

  /// Confirma cambios de edición.
  static const saveChangesCta = 'Guardar cambios';

  /// Validación genérica del formulario editable.
  static const invalidLotDetailsError = 'Revisá el nombre y la superficie.';

  /// Estado vacío de animales dentro del lote.
  static const noAnimalsInLotMessage = 'Este lote no tiene animales asignados.';

  /// Acción para iniciar un traslado local.
  /// Título del formulario de traslado.
  static const moveAnimalsTitle = 'Mover animales a otro lote';

  /// Etiqueta del destino.
  static const destinationLotLabel = 'Lote de destino';

  /// Etiqueta del motivo auditable.
  static const movementReasonLabel = 'Motivo';

  /// Etiqueta de fecha efectiva.
  static const movementDateLabel = 'Fecha del movimiento';

  /// Mensaje cuando no hay un destino válido.
  static const noMovementDestinationMessage = 'No hay otro lote activo disponible como destino.';

  /// Validación del formulario de movimiento.
  static const invalidMovementError = 'Seleccioná al menos un animal, un destino y escribí el motivo.';

  /// Fecha de alta local.
  static const createdAtLabel = 'Creado';

  /// Fecha del último cambio local.
  static const updatedAtLabel = 'Última actualización';

  /// Cantidad localizada de lotes activos.
  static String localLotCount(int count) => count == 1 ? '1 lote' : '$count lotes';

  /// Confirma la escritura durable al regresar del editor.
  static String lotSavedMessage(String name) => '$name quedó guardado en este dispositivo.';

  /// Etiqueta localizada de un estado operativo.
  static String statusName(LotStatus status) => switch (status) {
    LotStatus.active => 'Activo',
    LotStatus.resting => 'En descanso',
    LotStatus.maintenance => 'Mantenimiento',
    LotStatus.inactive => 'Inactivo',
    LotStatus.unknown => 'Estado desconocido',
  };

  /// Error por cantidad insuficiente de vértices.
  static const insufficientVerticesError = 'Marcá al menos 3 vértices distintos.';

  /// Error por coordenadas fuera del lienzo cartesiano local.
  static const invalidCoordinateError = 'Uno de los vértices tiene una coordenada inválida.';

  /// Error por repetir un punto.
  static const duplicateVertexError = 'Hay un vértice repetido.';

  /// Error por no encerrar superficie.
  static const zeroAreaError = 'El lote no encierra una superficie.';

  /// Error por cruce entre lados.
  static const selfIntersectionError = 'Los lados del lote se cruzan. Mové los vértices marcados.';

  /// Error cuando falta nombrar el borrador.
  static const requiredLotNameError = 'Ingresá un nombre para continuar.';

  /// Error cuando el polígono ocupa parte de otro lote.
  static const overlappingLotError = 'La delimitación se superpone con otro lote.';

  /// Feedback al intentar marcar dentro de una división existente.
  static const vertexInsideLotError = 'No podés marcar un vértice dentro de un lote existente.';
}
