import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

/// Registro que el backend rechazó y quedó guardado solo en el teléfono.
///
/// Un rechazo es definitivo (un error funcional del backend, no de red): la
/// cola ya no lo reintenta, así que hay que corregirlo desde su pantalla.
@immutable
class SyncRejectedRecord {
  /// Crea el registro rechazado.
  const SyncRejectedRecord({
    required this.localId,
    required this.kind,
    required this.recordedAt,
    this.errorCode,
  });

  /// UUID local del registro.
  final String localId;

  /// Tipo de registro.
  final SyncOperationKind kind;

  /// Último cambio local del registro.
  final DateTime recordedAt;

  /// Código funcional que devolvió el backend, si lo informó.
  final String? errorCode;

  @override
  bool operator ==(Object other) =>
      other is SyncRejectedRecord &&
      other.localId == localId &&
      other.kind == kind &&
      other.recordedAt == recordedAt &&
      other.errorCode == errorCode;

  @override
  int get hashCode => Object.hash(localId, kind, recordedAt, errorCode);
}

/// Registro que el backend aceptó durante esta sesión de la app.
@immutable
class SyncSentRecord {
  /// Crea el registro enviado.
  const SyncSentRecord({required this.localId, required this.kind, required this.sentAt});

  /// UUID local del registro.
  final String localId;

  /// Tipo de registro.
  final SyncOperationKind kind;

  /// Momento en que llegó la confirmación del backend.
  final DateTime sentAt;

  @override
  bool operator ==(Object other) =>
      other is SyncSentRecord && other.localId == localId && other.kind == kind && other.sentAt == sentAt;

  @override
  int get hashCode => Object.hash(localId, kind, sentAt);
}
