import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/entities/lot_movement.dart';

/// Acceso offline-first a catálogos y operaciones atómicas de ubicación.
abstract class LotMovementRepository {
  /// Lee datos locales y opcionalmente los actualiza desde los endpoints existentes.
  Future<Result<MovementContext>> getContext(String establishmentId, {bool refreshRemote = false});

  /// Guarda movimiento y ubicaciones en una única transacción.
  Future<Result<AnimalLotMovement>> save(AnimalLotMovement movement);

  /// Reencola la operación durable original sin generar otro UUID.
  Future<Result<void>> retry(String movementId);

  /// Cambios persistidos de confirmación, rechazo o historial.
  Stream<void> get changes;
}
