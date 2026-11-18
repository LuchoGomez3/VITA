import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

/// Fuente de la cola local de operaciones pendientes de sincronizar.
abstract interface class SyncQueueRepository {
  /// Emite la cola actual al suscribirse y cada vez que cambia.
  ///
  /// Funciona sin conexión: lee solamente SQLite del dispositivo. Un error de
  /// lectura se emite como `DomainException` sin cerrar el stream, para que la
  /// próxima lectura pueda recuperarse.
  Stream<SyncQueueSnapshot> watch();
}
