import 'dart:convert';

import 'package:frontend_mayoral/brick/models/health_event.model.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';

/// Traduce los registros sanitarios entre dominio, SQLite y el contrato REST.
abstract final class HealthCodec {
  /// Decodifica un objeto persistido.
  static Map<String, dynamic> object(String value) => jsonDecode(value) as Map<String, dynamic>;

  /// Reconstruye un catálogo de una respuesta o del caché.
  static HealthCatalog catalogFrom(Map<String, dynamic> json, String establishmentId) => HealthCatalog(
    establishmentId: establishmentId,
    practices: (json['practicas'] as List).cast<Map<String, dynamic>>().map(practiceFrom).toList(),
    products: (json['productos'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (item) => HealthProduct(id: item['id'] as String, name: item['nombre'] as String),
        )
        .toList(),
  );

  /// Conserva un catálogo en su formato de intercambio.
  static Map<String, Object?> catalogTo(HealthCatalog catalog) => {
    'practicas': catalog.practices.map(practiceTo).toList(),
    'productos': [
      for (final product in catalog.products) {'id': product.id, 'nombre': product.name},
    ],
  };

  /// Lee una práctica o la referencia conservada en un evento.
  static HealthPractice practiceFrom(Map<String, dynamic> json) => HealthPractice(
    id: json['id'] as String,
    name: json['nombre'] as String,
    kind: HealthPracticeKind.values.firstWhere((kind) => kind.code == json['modelo']),
    productIds: (json['producto_ids'] as List?)?.cast<String>() ?? const [],
  );

  /// Serializa una práctica y su variante.
  static Map<String, Object?> practiceTo(HealthPractice practice) => {
    'id': practice.id,
    'nombre': practice.name,
    'modelo': practice.kind.code,
    'producto_ids': practice.productIds,
  };

  /// Lee los datos de la práctica.
  static HealthEventDetails detailsFrom(Map<String, dynamic> json, HealthPracticeKind kind) => switch (kind) {
    HealthPracticeKind.application => HealthApplication(
      productId: json['producto_id'] as String,
      productName: json['producto_nombre'] as String,
      dose: json['dosis'].toString(),
      unit: json['unidad'] as String,
      route: json['via'] as String,
      batch: json['serie'] as String?,
      expirationDate: _date(json['vencimiento']),
    ),
    HealthPracticeKind.sampling || HealthPracticeKind.lesion => HealthObservation(
      description: json['descripcion'] as String,
      sampleType: json['tipo_muestra'] as String?,
    ),
  };

  /// Serializa datos comunes a los animales afectados.
  static Map<String, Object?> detailsTo(HealthEventDetails details) => switch (details) {
    HealthApplication() => {
      'producto_id': details.productId,
      'producto_nombre': details.productName,
      'dosis': details.dose.replaceAll(',', '.'),
      'unidad': details.unit,
      'via': details.route,
      'serie': details.batch,
      'vencimiento': details.expirationDate?.toIso8601String().split('T').first,
    },
    HealthObservation() => {'descripcion': details.description, 'tipo_muestra': details.sampleType},
  };

  /// Lee una selección guardada o confirmada remotamente.
  static HealthRecipient recipientFrom(Map<String, dynamic> json) => HealthRecipient(
    animalId: json['animal_id'] as String,
    label: json['caravana'] as String? ?? '',
    lotId: json['lote_id'] as String?,
    sampleReference: json['referencia_muestra'] as String?,
  );

  /// Datos que se conservan individualmente por animal.
  static Map<String, Object?> recipientTo(HealthRecipient recipient) => {
    'animal_id': recipient.animalId,
    'caravana': recipient.label,
    'lote_id': recipient.lotId,
    'referencia_muestra': recipient.sampleReference,
  };

  /// Lee solo los identificadores previstos en el contrato de rechazos.
  static HealthRejectionDetails? rejectionFrom(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final animalId = json['animal_id'];
    final field = json['campo'];
    final details = (animalId: animalId is String ? animalId : null, field: field is String ? field : null);
    return details.animalId == null && details.field == null ? null : details;
  }

  static Map<String, String?>? _rejectionTo(HealthRejectionDetails? rejection) =>
      rejection == null ? null : {'animal_id': rejection.animalId, 'campo': rejection.field};

  /// Lee un evento del historial. Las filas remotas tienen estado confirmado.
  static HealthEvent eventFrom(Map<String, dynamic> json, {bool remote = false}) {
    final practice = practiceFrom(json['practica'] as Map<String, dynamic>);
    final result = json['resultado'] as Map<String, dynamic>?;
    return HealthEvent(
      id: json['id'] as String,
      establishmentId: json['establecimiento_id'] as String,
      occurredAt: DateTime.parse(json['fecha_aplicacion'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      practice: practice,
      details: detailsFrom(json['datos'] as Map<String, dynamic>, practice.kind),
      responsible: json['responsable'] as String,
      recordedById: json['registrado_por_id'] as String,
      recipient: recipientFrom(json),
      notes: json['observaciones'] as String?,
      deletedAt: _date(json['deleted_at']),
      syncStatus: remote ? HealthSyncStatus.synchronized : HealthSyncStatus.values.byName(json['local_sync'] as String),
      syncErrorCode: remote ? null : json['local_sync_error'] as String?,
      resultErrorCode: remote ? null : json['local_result_error'] as String?,
      syncRejection: remote ? null : rejectionFrom(json['local_sync_rejection']),
      resultRejection: remote ? null : rejectionFrom(json['local_result_rejection']),
      resultSyncStatus: remote || json['local_result_sync'] == null
          ? null
          : HealthSyncStatus.values.byName(json['local_result_sync'] as String),
      result: result == null
          ? null
          : HealthStudyResult(
              value: result['valor'] as String,
              reportedAt: DateTime.parse(result['fecha'] as String),
              reportedById: result['registrado_por_id'] as String,
            ),
    );
  }

  /// Guarda una proyección local para lectura offline.
  static BrickHealthEventModel eventRow(HealthEvent event) => BrickHealthEventModel(
    localId: event.id,
    establishmentId: event.establishmentId,
    animalId: event.recipient.animalId,
    payload: jsonEncode({
      ...recipientTo(event.recipient),
      'id': event.id,
      'establecimiento_id': event.establishmentId,
      'fecha_aplicacion': event.occurredAt.toUtc().toIso8601String(),
      'created_at': event.createdAt.toUtc().toIso8601String(),
      'updated_at': event.updatedAt.toUtc().toIso8601String(),
      'practica': practiceTo(event.practice),
      'datos': detailsTo(event.details),
      'responsable': event.responsible,
      'registrado_por_id': event.recordedById,
      'observaciones': event.notes,
      'deleted_at': event.deletedAt?.toUtc().toIso8601String(),
      'local_sync': event.syncStatus.name,
      'local_sync_error': event.syncErrorCode,
      'local_result_error': event.resultErrorCode,
      'local_sync_rejection': _rejectionTo(event.syncRejection),
      'local_result_rejection': _rejectionTo(event.resultRejection),
      'local_result_sync': event.resultSyncStatus?.name,
      'resultado': switch (event.result) {
        final value? => {
          'valor': value.value,
          'fecha': value.reportedAt.toUtc().toIso8601String(),
          'registrado_por_id': value.reportedById,
        },
        null => null,
      },
    }),
  );

  static DateTime? _date(Object? value) => value is String ? DateTime.parse(value) : null;
}
