import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';

part 'health_event.freezed.dart';

/// Datos de una aplicación de producto o de una observación o estudio.
@freezed
sealed class HealthEventDetails with _$HealthEventDetails {
  /// Aplicación de un producto seleccionado del catálogo.
  const factory HealthEventDetails.application({
    required String productId,
    required String productName,
    required String dose,
    required String unit,
    required String route,
    String? batch,
    DateTime? expirationDate,
  }) = HealthApplication;

  /// Observación o estudio. El muestreo requiere también tipo de muestra.
  const factory HealthEventDetails.observation({
    required String description,
    String? sampleType,
  }) = HealthObservation;
}

/// Estado de envío del alta o del resultado.
enum HealthSyncStatus {
  /// Guardado en el dispositivo y pendiente de aceptación remota.
  pending,

  /// Aceptado por el servidor.
  synchronized,

  /// Rechazado por el servidor.
  rejected,
}

/// Ubicación del dato que el servidor rechazó.
typedef HealthRejectionDetails = ({String? animalId, String? field});

/// Registro rechazado y los datos que el operario puede corregir.
typedef HealthCorrection = ({String id, HealthRegistration registration, HealthRejectionDetails? rejection});

/// Animal seleccionado para recibir una práctica.
@freezed
sealed class HealthRecipient with _$HealthRecipient {
  /// Conserva la identidad y los datos específicos de la muestra.
  const factory HealthRecipient({
    required String animalId,
    required String label,
    String? lotId,
    String? sampleReference,
  }) = _HealthRecipient;
}

/// Datos comunes que se confirman para la selección revisada.
@freezed
sealed class HealthRegistration with _$HealthRegistration {
  /// Crea una operación de registro lista para validar.
  const factory HealthRegistration({
    required String establishmentId,
    required DateTime occurredAt,
    required HealthPractice practice,
    required HealthEventDetails details,
    required String responsible,
    required List<HealthRecipient> recipients,
    String? notes,
  }) = _HealthRegistration;
}

/// Primer resultado informado para un estudio.
@freezed
sealed class HealthStudyResult with _$HealthStudyResult {
  /// Conserva el resultado y la fecha en que se informó.
  const factory HealthStudyResult({
    required String value,
    required DateTime reportedAt,
    required String reportedById,
  }) = _HealthStudyResult;
}

/// Registro individual que se muestra en el historial.
@freezed
sealed class HealthEvent with _$HealthEvent {
  /// Crea un evento del historial local.
  const factory HealthEvent({
    required String id,
    required String establishmentId,
    required DateTime occurredAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required HealthPractice practice,
    required HealthEventDetails details,
    required String responsible,
    required String recordedById,
    required HealthRecipient recipient,
    @Default(HealthSyncStatus.pending) HealthSyncStatus syncStatus,
    HealthSyncStatus? resultSyncStatus,
    String? syncErrorCode,
    String? resultErrorCode,
    HealthRejectionDetails? syncRejection,
    HealthRejectionDetails? resultRejection,
    HealthStudyResult? result,
    String? notes,
    DateTime? deletedAt,
  }) = _HealthEvent;
}
