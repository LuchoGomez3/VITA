// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'senasa_report_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SenasaReportRequestDto _$SenasaReportRequestDtoFromJson(
  Map<String, dynamic> json,
) => _SenasaReportRequestDto(
  establishmentId: json['establecimientoId'] as String,
  from: json['desde'] as String,
  to: json['hasta'] as String,
  filename: json['nombreArchivo'] as String,
);

Map<String, dynamic> _$SenasaReportRequestDtoToJson(
  _SenasaReportRequestDto instance,
) => <String, dynamic>{
  'establecimientoId': instance.establishmentId,
  'desde': instance.from,
  'hasta': instance.to,
  'nombreArchivo': instance.filename,
};

_SenasaEstablishmentDto _$SenasaEstablishmentDtoFromJson(
  Map<String, dynamic> json,
) => _SenasaEstablishmentDto(
  id: json['id'] as String,
  name: json['name'] as String,
  renspa: json['renspa_number'] as String?,
);

Map<String, dynamic> _$SenasaEstablishmentDtoToJson(
  _SenasaEstablishmentDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'renspa_number': instance.renspa,
};

_SenasaRecordIssueDto _$SenasaRecordIssueDtoFromJson(
  Map<String, dynamic> json,
) => _SenasaRecordIssueDto(
  animalId: json['animal_id'] as String,
  missingFields: (json['faltante'] as List<dynamic>).map((e) => e as String).toList(),
  tag: json['caravana'] as String?,
);

Map<String, dynamic> _$SenasaRecordIssueDtoToJson(
  _SenasaRecordIssueDto instance,
) => <String, dynamic>{
  'animal_id': instance.animalId,
  'faltante': instance.missingFields,
  'caravana': instance.tag,
};

_SenasaValidationResultDto _$SenasaValidationResultDtoFromJson(
  Map<String, dynamic> json,
) => _SenasaValidationResultDto(
  exportableAnimals: (json['cantidad_exportable'] as num).toInt(),
  issues: (json['animales_incompletos'] as List<dynamic>)
      .map((e) => SenasaRecordIssueDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SenasaValidationResultDtoToJson(
  _SenasaValidationResultDto instance,
) => <String, dynamic>{
  'cantidad_exportable': instance.exportableAnimals,
  'animales_incompletos': instance.issues,
};

_SenasaExportHistoryItemDto _$SenasaExportHistoryItemDtoFromJson(
  Map<String, dynamic> json,
) => _SenasaExportHistoryItemDto(
  id: json['id'] as String,
  establishmentId: json['establecimiento_id'] as String,
  filename: json['nombre_archivo'] as String,
  mediaType: json['media_type'] as String,
  animalCount: (json['cantidad_animales'] as num).toInt(),
  generatedAt: DateTime.parse(json['created_at'] as String),
  from: json['desde'] == null ? null : DateTime.parse(json['desde'] as String),
  to: json['hasta'] == null ? null : DateTime.parse(json['hasta'] as String),
);

Map<String, dynamic> _$SenasaExportHistoryItemDtoToJson(
  _SenasaExportHistoryItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'establecimiento_id': instance.establishmentId,
  'nombre_archivo': instance.filename,
  'media_type': instance.mediaType,
  'cantidad_animales': instance.animalCount,
  'created_at': instance.generatedAt.toIso8601String(),
  'desde': instance.from?.toIso8601String(),
  'hasta': instance.to?.toIso8601String(),
};
