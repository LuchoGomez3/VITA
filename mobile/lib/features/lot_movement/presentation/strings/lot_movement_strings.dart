import 'package:frontend_mayoral/features/lot_movement/domain/entities/lot_movement.dart';

/// Fuente única de textos para asignaciones, traslados e historial.
abstract final class LotMovementStrings {
  /// Título de la pantalla compartida por ficha y campo.
  static const title = 'Cambiar de lote';

  /// Etiquetas del formulario.
  static const origin = 'Origen';

  /// Primera asignación: origen sin lote.
  static const withoutLot = 'Sin lote asignado';

  /// Lote activo que recibirá la selección.
  static const destination = 'Lote de destino';

  /// Encabezado de la selección múltiple.
  static const animals = 'Seleccioná los animales';

  /// Motivo obligatorio del hecho histórico.
  static const reason = 'Motivo del movimiento';

  /// Día efectivo elegido para el movimiento.
  static const date = 'Fecha del movimiento';

  /// Hora efectiva, en la zona horaria del dispositivo.
  static const time = 'Hora del movimiento';

  /// Abre la confirmación previa al guardado.
  static const review = 'Revisar movimiento';

  /// Guarda después de revisar origen y destino.
  static const confirm = 'Confirmar';

  /// Cierra la confirmación sin guardar.
  static const cancel = 'Cancelar';

  /// Reencola el mismo movimiento.
  static const retry = 'Reintentar';

  /// Estados vacíos y de validación.
  static const emptySelection = 'Seleccioná al menos un animal.';

  /// Estado vacío del grupo de origen.
  static const noAnimals = 'No hay animales de este origen disponibles en el dispositivo.';

  /// Estado vacío de destinos activos.
  static const noDestinations =
      'No hay otros lotes activos sincronizados disponibles. Los lotes creados sólo en el celular deben sincronizarse primero.';

  /// Pide completar destino y motivo.
  static const invalidForm = 'Elegí un destino e ingresá el motivo.';

  /// Explica por qué un animal no puede seleccionarse.
  static const unavailableAnimal = 'Tiene otro traslado pendiente o rechazado.';

  /// Informa que se trabaja con el catálogo local.
  static const cached =
      'Se usan los datos guardados en el dispositivo. El servidor validará el movimiento al sincronizar.';

  /// Guardado local e historial de resultados.
  static const pendingSaved = 'Movimiento guardado en el dispositivo. Pendiente de sincronización.';

  /// Título del historial durable.
  static const history = 'Historial de movimientos';

  /// Estado vacío del historial.
  static const emptyHistory = 'Todavía no hay movimientos registrados.';

  /// Encabezado del resumen previo a guardar.
  static const confirmationTitle = 'Confirmar movimiento';

  /// Confirma explícitamente el grupo que se trasladará antes de escribir SQLite.
  static String confirmation(int count, String source, String destination) =>
      '${animalCount(count)}\nOrigen: $source\nDestino: $destination';

  /// Cantidad explícita de animales para confirmación e historial.
  static String animalCount(int count) => '$count ${count == 1 ? 'animal' : 'animales'}';

  /// Mensaje legible más código autoritativo para revisar el rechazo.
  static String rejected(String? code) => isReleased(code)
      ? 'El destino no estaba sincronizado. Los animales volvieron al origen y podés moverlos a otro lote. Se conserva el intento rechazado.'
      : 'El servidor rechazó este movimiento${code == null ? '.' : ' ($code).'} La operación se conserva para revisión.';

  /// Identifica un rechazo conservado cuyo efecto local ya fue liberado.
  static bool isReleased(String? code) => code?.startsWith('released_local_destination:') ?? false;

  /// Presenta confirmaciones por separado de los pendientes locales.
  static String status(MovementSyncStatus status) => switch (status) {
    MovementSyncStatus.pending => 'Pendiente de sincronización',
    MovementSyncStatus.synchronized => 'Confirmado por el servidor',
    MovementSyncStatus.rejected => 'Rechazado por el servidor',
  };
}
