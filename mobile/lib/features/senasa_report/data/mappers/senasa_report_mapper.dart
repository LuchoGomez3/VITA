import 'package:frontend_mayoral/features/senasa_report/data/dtos/senasa_report_dtos.dart';
import 'package:frontend_mayoral/features/senasa_report/data/models/senasa_report_file_data.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';

/// Traduce contratos de dominio a DTOs aceptados por el backend.
extension SenasaReportRequestMapper on SenasaReportRequest {
  /// Convierte los filtros de generación al contrato de transporte.
  SenasaReportRequestDto toDto() => SenasaReportRequestDto(
    establishmentId: establishmentId,
    from: from.toUtc().toIso8601String(),
    to: to.toUtc().toIso8601String(),
    filename: fileName,
  );
}

/// Traduce la validación de dominio al contrato de transporte compartido.
extension SenasaReportValidationRequestMapper on SenasaReportValidationRequest {
  /// Convierte los filtros de validación al DTO enviado a la API.
  SenasaReportRequestDto toDto() => SenasaReportRequestDto(
    establishmentId: establishmentId,
    from: from.toUtc().toIso8601String(),
    to: to.toUtc().toIso8601String(),
    filename: fileName,
  );
}

/// Traduce un establecimiento persistido a una entidad de dominio.
extension SenasaEstablishmentMapper on SenasaEstablishmentDto {
  /// Elimina del dominio los detalles del formato almacenado.
  SenasaEstablishment toDomain() => SenasaEstablishment(
    id: id,
    name: name,
    renspa: renspa,
  );
}

/// Traduce el resultado técnico de validación a dominio.
extension SenasaValidationResultMapper on SenasaValidationResultDto {
  /// Construye el resultado usado por el Cubit sin exponer DTOs.
  SenasaValidationResult toDomain() => SenasaValidationResult(
    exportableAnimals: exportableAnimals,
    issues: issues
        .map(
          (issue) => SenasaRecordIssue(
            animalId: issue.animalId,
            tag: issue.tag,
            missingFields: issue.missingFields,
          ),
        )
        .toList(growable: false),
  );
}

/// Traduce los metadatos remotos de una exportación a dominio.
extension SenasaExportHistoryItemMapper on SenasaExportHistoryItemDto {
  /// Construye la entidad consumida por el historial de la feature.
  SenasaExportHistoryItem toDomain() => SenasaExportHistoryItem(
    id: id,
    establishmentId: establishmentId,
    filename: filename,
    mediaType: mediaType,
    animalCount: animalCount,
    generatedAt: generatedAt,
    from: from,
    to: to,
  );
}

/// Traduce la respuesta binaria del data source a un archivo de dominio.
extension SenasaReportFileMapper on SenasaReportFileData {
  /// Completa los metadatos de negocio que no forman parte de HTTP.
  GeneratedSenasaReport toDomain({required int animalCount}) => GeneratedSenasaReport(
    bytes: bytes,
    filename: filename,
    mediaType: mediaType,
    generatedAt: DateTime.now(),
    animalCount: animalCount,
  );
}
