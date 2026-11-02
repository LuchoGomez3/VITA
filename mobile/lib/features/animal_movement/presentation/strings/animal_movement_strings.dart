import 'package:frontend_mayoral/core/constants/feature_strings.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/errors/movement_failure.dart';

/// Textos de los movimientos entre potreros.
abstract final class AnimalMovementStrings {
  /// Título de la pantalla de movimiento.
  static const String pageTitle = FeatureStrings.moveAnimals;

  /// Explicación arriba de la lectura de caravanas.
  static const readHint =
      'Leé con el bastón las caravanas de los animales que vas a mover. '
      'Elegí RFID para ingresar exactamente 15 números o caravana visual para buscar por ese identificador.';

  /// Opción de lectura electrónica con formato estricto.
  static const rfidMode = 'RFID';

  /// Opción de identificación visual independiente del RFID.
  static const visualMode = 'Caravana visual';

  /// Ayuda del ingreso electrónico.
  static const rfidFieldHint = '15 números RFID';

  /// Validación compartida con los ingresos electrónicos del resto de la app.
  static const invalidRfid = 'Ingresá exactamente 15 números para el RFID.';

  /// Botón para agregar la caravana escrita.
  static const addTag = 'Agregar';

  /// Título de la lista de animales.
  static String animalsTitle(int count) => 'Animales a mover · $count';

  /// Línea del potrero de origen.
  static String fromLot(String lotName) => 'Desde ${lotName.isEmpty ? 'potrero sin nombre' : lotName}';

  /// Animal que ya está en el destino elegido.
  static const alreadyInDestination = 'Ya está en este potrero';

  /// Quitar un animal de la lista.
  static const removeAnimal = 'Quitar de la lista';

  /// Título de los potreros de destino.
  static const destinationTitle = 'Potrero de destino';

  /// Subtítulo de cada potrero.
  static String destinationAnimals(int count) => count == 1 ? '1 animal actualmente' : '$count animales actualmente';

  /// Sin potreros para elegir.
  static const noDestinations = 'Este establecimiento no tiene potreros activos. Creá uno en "Campo y potreros".';

  /// Etiqueta del motivo.
  static const reasonLabel = 'Motivo';

  /// Placeholder del motivo.
  static const reasonHint = 'Por ejemplo: rotación de pastoreo';

  /// Etiqueta de la fecha.
  static String dateLabel(String date) => 'Fecha: $date';

  /// Botón principal.
  static String submit(int count) => count == 1 ? 'Mover 1 animal' : 'Mover $count animales';

  /// Falta elegir el destino.
  static const chooseDestination = 'Elegí el potrero de destino.';

  /// Animal inicial no disponible para traslado.
  static const animalUnavailable = 'Este animal no se puede mover: no está activo o no tiene potrero.';

  /// Validación de lectura vacía.
  static const tagRequired = 'Leé o escribí una caravana.';

  /// Caravana sin coincidencia en el caché.
  static String tagNotFound(String tag) => 'No hay ningún animal activo con la caravana $tag en el celular.';

  /// Evita agregar un animal arbitrario cuando hay identificaciones repetidas.
  static String ambiguousTag(String tag) =>
      'La identificación $tag coincide con varios animales. Leé un RFID único o revisá las caravanas.';

  /// La selección no puede mezclar establecimientos.
  static const differentEstablishment = 'Ese animal es de otro establecimiento: los potreros son de un solo campo.';

  /// Una identificación repetida no agrega otra fila.
  static String alreadySelected(String tag) => 'La caravana $tag ya está en la lista.';

  /// Validación de selección vacía.
  static const animalsRequired = 'Agregá al menos un animal.';

  /// Validación del motivo operativo.
  static const reasonRequired = 'Ingresá el motivo del movimiento.';

  /// Selección que no cambiaría la ubicación de ningún animal.
  static const allAlreadyThere = 'Todos los animales ya están en ese potrero.';

  /// Lectura local fallida del animal inicial.
  static const animalReadError = 'No se pudo leer el animal guardado en el celular.';

  /// Lectura local fallida al identificar una caravana.
  static const tagReadError = 'No se pudo leer la caravana guardada en el celular.';

  /// Lectura local fallida de los destinos.
  static const destinationsReadError = 'No se pudieron leer los potreros guardados en el celular.';

  /// Lectura local fallida del historial.
  static const historyReadError = 'No se pudo leer el historial guardado en el celular.';

  /// Falla de guardado que no tiene un motivo específico del flujo.
  static const saveError = 'No se pudo guardar el movimiento en el dispositivo.';

  /// Una ubicación cambió desde que se preparó la selección.
  static const movementConflict = 'La ubicación de un animal cambió. Revisá la selección antes de volver a mover.';

  /// El comando compartido no encontró el destino o dejó de admitir animales.
  static const destinationUnavailable = 'El potrero de destino no está disponible o no admite animales.';

  /// Operación incompleta después de guardar otros grupos.
  static String partialFailure(int movedCount, String cause) =>
      '${movedCount == 1 ? 'Se movió 1 animal' : 'Se movieron $movedCount animales'}, pero el resto no: $cause '
      'Revisá la lista y volvé a intentar con los que faltan.';

  /// Traduce los motivos del dominio sin mostrar identificadores técnicos.
  static String errorMessage(DomainException error) => switch (error.reason) {
    MovementAnimalUnavailable() => animalUnavailable,
    MovementTagRequired() => tagRequired,
    MovementInvalidRfid() => invalidRfid,
    MovementTagNotFound(:final tag) => tagNotFound(tag),
    MovementAmbiguousTag(:final tag) => ambiguousTag(tag),
    MovementDifferentEstablishment() => differentEstablishment,
    MovementAlreadySelected(:final visualTag) => alreadySelected(visualTag),
    MovementAnimalsRequired() => animalsRequired,
    MovementReasonRequired() => reasonRequired,
    MovementDestinationRequired() => chooseDestination,
    MovementAllAlreadyThere() => allAlreadyThere,
    MovementLocalReadFailure(:final target) => switch (target) {
      MovementReadTarget.animal => animalReadError,
      MovementReadTarget.tag => tagReadError,
      MovementReadTarget.destinations => destinationsReadError,
      MovementReadTarget.history => historyReadError,
    },
    MovementPartialFailure(:final movedCount, :final cause) => partialFailure(movedCount, errorMessage(cause)),
    _ => switch (error.code) {
      DomainErrorCode.conflict => movementConflict,
      DomainErrorCode.notFound || DomainErrorCode.validation => destinationUnavailable,
      _ => saveError,
    },
  };
}
