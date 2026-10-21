/// Textos de los movimientos entre potreros.
abstract final class AnimalMovementStrings {
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

  /// Movimiento que todavía no llegó al servidor.
  static const pendingSync = 'Pendiente de sincronizar';

  /// Ayuda del botón flotante de la pestaña.
  static const moveTooltip = 'Mover animales';

  /// Título de la pantalla de movimiento.
  static const pageTitle = 'Mover animales';

  /// Explicación arriba de la lectura de caravanas.
  static const readHint =
      'Leé con el bastón las caravanas de los animales que vas a mover. '
      'También podés escribir la caravana visual o el RFID.';

  /// Placeholder del campo de lectura.
  static const tagFieldHint = 'Caravana o RFID';

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

  /// Confirmación al volver a la ficha.
  static String moved(int count, String destination) =>
      count == 1 ? 'Se movió 1 animal a $destination.' : 'Se movieron $count animales a $destination.';

  /// Aclaración offline de la confirmación.
  static const savedOffline = 'Queda guardado en el celular y se sincroniza con señal.';
}
