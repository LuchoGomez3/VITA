import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';

/// Registros que el backend rechazó y siguen guardados en el teléfono.
abstract interface class SyncRejectionsRepository {
  /// Emite los rechazados al suscribirse y cada vez que cambian, el más
  /// reciente primero.
  ///
  /// Lee solo SQLite del dispositivo. Un error de lectura se emite como
  /// `DomainException` sin cerrar el stream.
  Stream<List<SyncRejectedRecord>> watch();
}

/// Registros que el backend aceptó durante la sesión actual de la app.
abstract interface class SyncHistoryRepository {
  /// Emite el historial al suscribirse y con cada envío aceptado, el más
  /// reciente primero.
  Stream<List<SyncSentRecord>> watch();
}
