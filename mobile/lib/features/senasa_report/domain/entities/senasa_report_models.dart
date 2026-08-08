import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'senasa_report_models.freezed.dart';

/// An establishment available to the authenticated user.
@freezed
sealed class SenasaEstablishment with _$SenasaEstablishment {
  /// Creates an establishment used by SENASA report filters.
  const factory SenasaEstablishment({
    required String id,
    required String name,
    String? renspa,
  }) = _SenasaEstablishment;
}

/// Parámetros aceptados por la declaración inicial de dispositivos.
@freezed
sealed class SenasaReportRequest with _$SenasaReportRequest {
  /// Crea una solicitud para generar el TXT oficial desde el backend.
  const factory SenasaReportRequest({
    required String establishmentId,
    required DateTime from,
    required DateTime to,
    required String fileName,
    required int animalCount,
  }) = _SenasaReportRequest;
}

/// Filtros necesarios para comprobar que los registros pueden exportarse.
@freezed
sealed class SenasaReportValidationRequest with _$SenasaReportValidationRequest {
  /// Crea una solicitud de validación que no genera ni guarda una exportación.
  const factory SenasaReportValidationRequest({
    required String establishmentId,
    required DateTime from,
    required DateTime to,
    required String fileName,
  }) = _SenasaReportValidationRequest;
}

/// Animal que no puede incluirse en el documento y campos que debe completar.
@freezed
sealed class SenasaRecordIssue with _$SenasaRecordIssue {
  /// Crea el detalle de un registro rechazado por la validación.
  const factory SenasaRecordIssue({
    required String animalId,
    required List<String> missingFields,
    String? tag,
  }) = _SenasaRecordIssue;
}

/// Resultado completo de la validación previa del documento SENASA.
@freezed
sealed class SenasaValidationResult with _$SenasaValidationResult {
  /// Crea el resultado con la cantidad exportable y los registros inválidos.
  const factory SenasaValidationResult({
    required int exportableAnimals,
    @Default(<SenasaRecordIssue>[]) List<SenasaRecordIssue> issues,
  }) = _SenasaValidationResult;
}

/// File returned by the SENASA report endpoint.
@freezed
sealed class GeneratedSenasaReport with _$GeneratedSenasaReport {
  /// Creates a generated report file.
  const factory GeneratedSenasaReport({
    required Uint8List bytes,
    required String filename,
    required String mediaType,
    required DateTime generatedAt,
    required int animalCount,
  }) = _GeneratedSenasaReport;
}

/// Metadatos remotos de una declaración generada anteriormente.
@freezed
sealed class SenasaExportHistoryItem with _$SenasaExportHistoryItem {
  /// Crea una entrada del historial sin cargar todavía los bytes del archivo.
  const factory SenasaExportHistoryItem({
    required String id,
    required String establishmentId,
    required String filename,
    required String mediaType,
    required int animalCount,
    required DateTime generatedAt,
    DateTime? from,
    DateTime? to,
  }) = _SenasaExportHistoryItem;
}
