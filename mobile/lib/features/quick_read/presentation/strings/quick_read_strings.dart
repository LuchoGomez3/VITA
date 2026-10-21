/// Textos del lector de caravanas (botón central).
abstract final class QuickReadStrings {
  /// Etiqueta del botón central cerrado.
  static const read = 'Leer';

  /// Etiqueta del botón central con el panel abierto.
  static const close = 'Cerrar';

  /// Ayuda del botón central.
  static const readTooltip = 'Leer caravanas';

  /// Título mientras espera lecturas.
  static const waitingTitle = 'Acercá el bastón a la caravana';

  /// Texto mientras espera lecturas.
  static const waitingBody =
      'Podés leer una sola o seguir pasando animales por la manga. Las acciones aparecen según cuántas leas.';

  /// Estado del lector sin lecturas.
  static const ready = 'Listo para leer';

  /// Estado con una lectura.
  static const oneRead = '1 leída';

  /// Estado con varias lecturas.
  static const keepReading = 'Sigue leyendo';

  /// Botón para escribir la caravana.
  static const manualEntry = 'Ingresar caravana a mano';

  /// Placeholder del campo manual.
  static const manualHint = 'Caravana visual o RFID';

  /// Agregar la caravana escrita.
  static const add = 'Agregar';

  /// Pie con una sola lectura.
  static const keepReadingMore = 'Seguí leyendo más caravanas';

  /// Título de las acciones.
  static const whatToDo = '¿Qué querés hacer?';

  /// Acción pesar.
  static const registerWeight = 'Registrar peso';

  /// Subtítulo con el último peso.
  static String lastWeight(String kg) => 'Último: $kg kg';

  /// Subtítulo sin pesajes.
  static const noWeight = 'Sin pesajes';

  /// Acción tratamiento.
  static const registerTreatment = 'Registrar tratamiento';

  /// Tratamiento todavía no disponible.
  static const comingSoon = 'Próximamente';

  /// Acción mover.
  static const moveLot = 'Mover de lote';

  /// Subtítulo con el potrero actual.
  static String currentLot(String lot) => 'Hoy en ${lot.isEmpty ? 'un potrero' : lot}';

  /// Acción ficha.
  static const goToRecord = 'Ir a la ficha';

  /// Subtítulo de la ficha.
  static const fullHistory = 'Historial completo';

  /// Título de la caravana sin registrar.
  static const unregisteredTitle = 'Caravana sin registrar';

  /// Detalle de la caravana sin registrar.
  static String notInEstablishment(String establishment) =>
      establishment.isEmpty ? 'No está en el celular' : 'No figura en $establishment';

  /// Acción de alta.
  static const registerAnimal = 'Registrar nuevo animal';

  /// Subtítulo del alta.
  static const tagFillsItself = 'La caravana se completa sola';

  /// Nota bajo las acciones deshabilitadas.
  static const afterRegistering = 'Disponibles después de dar de alta el animal.';

  /// Vaciar la sesión.
  static const discard = 'Descartar';

  /// Confirmación de descartar.
  static const discardQuestion = '¿Descartar las caravanas leídas?';

  /// Explicación de descartar.
  static const discardBody = 'Se vacía la lista. No se borra nada de lo que ya registraste.';

  /// Cancelar.
  static const cancel = 'Cancelar';

  /// Etiqueta del total.
  static const readTags = 'Caravanas leídas';

  /// Chip de registradas.
  static String registered(int count) => '$count registradas';

  /// Chip de sin registrar.
  static String unregistered(int count) => '$count sin registrar';

  /// Abrir la lista completa.
  static String moreTags(int count) => count == 1 ? '+ 1 caravana más' : '+ $count caravanas más';

  /// Ver la lista.
  static const seeList = 'Ver lista';

  /// Ocultar la lista.
  static const hideList = 'Ocultar lista';

  /// Título de las acciones en grupo.
  static String applyTo(int count) => count == 1 ? 'Aplicar a la registrada' : 'Aplicar a las $count registradas';

  /// Subtítulo de las acciones en grupo.
  static String allTogether(int count) => count == 1 ? 'A la registrada' : 'A las $count juntas';

  /// Alta en serie.
  static String registerNewAnimals(int count) =>
      count == 1 ? 'Registrar 1 animal nuevo' : 'Registrar $count animales nuevos';

  /// Subtítulo del alta en serie.
  static const registerUnregisteredTags = 'Alta de las caravanas sin registrar';

  /// Quitar de la lista.
  static const remove = 'Quitar de la lista';

  /// Elegir el campo antes de un alta.
  static const chooseEstablishment = '¿En qué establecimiento lo das de alta?';
}
