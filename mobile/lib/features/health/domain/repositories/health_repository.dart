import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';

/// Operaciones de Sanidad disponibles sin conexión.
abstract interface class HealthRepository {
  /// Lee el último catálogo disponible para el establecimiento.
  Future<HealthCatalog?> getCatalog(String establishmentId);

  /// Devuelve los animales vigentes de la selección solicitada.
  Future<List<HealthRecipient>> getRecipients(String establishmentId, List<String> animalIds);

  /// Resuelve una caravana en el establecimiento activo.
  Future<HealthRecipient?> findRecipient(String establishmentId, String tag, {required bool electronic});

  /// Lee los eventos visibles del animal y observa sus cambios locales.
  Stream<List<HealthEvent>> watchHistory(String establishmentId, String animalId);

  /// Guarda una práctica para todos los animales de la selección.
  Future<void> register(HealthRegistration registration, {String? replacingOperationId});

  /// Completa un estudio existente con su primer resultado.
  Future<void> recordResult(HealthEvent event, String result, DateTime reportedAt);

  /// Recupera el formulario de un registro rechazado propio.
  Future<HealthCorrection?> getRejectedRegistration(HealthEvent event);
}
