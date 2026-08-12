import 'package:freezed_annotation/freezed_annotation.dart';

part 'senasa_report_dtos.freezed.dart';
part 'senasa_report_dtos.g.dart';

/// DTO con los filtros que esperan los endpoints de validación y generación.
@freezed
sealed class SenasaReportRequestDto with _$SenasaReportRequestDto {
  /// Crea el contrato serializable enviado al backend.
  const factory SenasaReportRequestDto({
    @JsonKey(name: 'establecimientoId') required String establishmentId,
    @JsonKey(name: 'desde') required String from,
    @JsonKey(name: 'hasta') required String to,
    @JsonKey(name: 'nombreArchivo') required String filename,
  }) = _SenasaReportRequestDto;

  /// Deserializa el contrato cuando sea necesario inspeccionarlo en pruebas.
  factory SenasaReportRequestDto.fromJson(Map<String, Object?> json) => _$SenasaReportRequestDtoFromJson(json);
}

/// DTO de un establecimiento almacenado por la sincronización inicial.
@freezed
sealed class SenasaEstablishmentDto with _$SenasaEstablishmentDto {
  /// Crea la representación persistida del establecimiento.
  const factory SenasaEstablishmentDto({
    required String id,
    required String name,
    @JsonKey(name: 'renspa_number') String? renspa,
  }) = _SenasaEstablishmentDto;

  /// Convierte el JSON de secure storage a un DTO tipado.
  factory SenasaEstablishmentDto.fromJson(Map<String, Object?> json) => _$SenasaEstablishmentDtoFromJson(json);
}

/// DTO de un animal que no cumple los requisitos de exportación.
@freezed
sealed class SenasaRecordIssueDto with _$SenasaRecordIssueDto {
  /// Crea el detalle técnico devuelto por el backend.
  const factory SenasaRecordIssueDto({
    @JsonKey(name: 'animal_id') required String animalId,
    @JsonKey(name: 'faltante') required List<String> missingFields,
    @JsonKey(name: 'caravana') String? tag,
  }) = _SenasaRecordIssueDto;

  /// Convierte la respuesta JSON a un DTO tipado.
  factory SenasaRecordIssueDto.fromJson(Map<String, Object?> json) => _$SenasaRecordIssueDtoFromJson(json);
}

/// DTO del resultado de la validación previa a la exportación.
@freezed
sealed class SenasaValidationResultDto with _$SenasaValidationResultDto {
  /// Crea el resultado técnico recibido desde la API.
  const factory SenasaValidationResultDto({
    @JsonKey(name: 'cantidad_exportable') required int exportableAnimals,
    @JsonKey(name: 'animales_incompletos') required List<SenasaRecordIssueDto> issues,
  }) = _SenasaValidationResultDto;

  /// Convierte la respuesta JSON normalizada a un DTO tipado.
  factory SenasaValidationResultDto.fromJson(Map<String, Object?> json) => _$SenasaValidationResultDtoFromJson(json);
}

/// DTO con los metadatos de una exportación histórica.
@freezed
sealed class SenasaExportHistoryItemDto with _$SenasaExportHistoryItemDto {
  /// Crea la representación de datos de una exportación remota.
  const factory SenasaExportHistoryItemDto({
    required String id,
    @JsonKey(name: 'establecimiento_id') required String establishmentId,
    @JsonKey(name: 'nombre_archivo') required String filename,
    @JsonKey(name: 'media_type') required String mediaType,
    @JsonKey(name: 'cantidad_animales') required int animalCount,
    @JsonKey(name: 'created_at') required DateTime generatedAt,
    @JsonKey(name: 'desde') DateTime? from,
    @JsonKey(name: 'hasta') DateTime? to,
  }) = _SenasaExportHistoryItemDto;

  /// Convierte los metadatos JSON a un DTO tipado.
  factory SenasaExportHistoryItemDto.fromJson(Map<String, Object?> json) => _$SenasaExportHistoryItemDtoFromJson(json);
}
