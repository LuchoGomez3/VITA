import 'dart:convert';

import 'package:frontend_mayoral/features/senasa_report/data/dtos/senasa_report_dtos.dart';
import 'package:frontend_mayoral/features/senasa_report/data/models/senasa_report_file_data.dart';
import 'package:frontend_mayoral/features/senasa_report/data/services/senasa_report_api_service.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';
import 'package:http/http.dart' as http;

/// Interpreta las respuestas HTTP de SENASA como modelos tipados de datos.
class SenasaReportRemoteDataSource {
  /// Crea el data source sobre el servicio de transporte autenticado.
  const SenasaReportRemoteDataSource({required SenasaReportApiService service}) : _service = service;

  final SenasaReportApiService _service;

  /// Obtiene los metadatos remotos del historial solicitado.
  Future<List<SenasaExportHistoryItemDto>> getGeneratedReports(
    String establishmentId,
  ) async {
    final data = _dataFrom(await _service.getGeneratedReports(establishmentId));
    if (data is! List<Object?>) {
      throw const SenasaReportException(
        message: 'El historial recibido no es válido.',
      );
    }
    return data.map(_parseHistoryItem).toList(growable: false);
  }

  /// Valida los registros y devuelve el resultado técnico de la API.
  Future<SenasaValidationResultDto> validateRecords(
    SenasaReportRequestDto request,
  ) async {
    final data = _dataFrom(await _service.validateRecords(request.toJson()));
    if (data is! Map<String, Object?>) {
      throw const SenasaReportException(
        message: 'La validación recibida no es válida.',
      );
    }
    return SenasaValidationResultDto.fromJson(_normalizeValidation(data));
  }

  /// Genera una declaración y conserva sus metadatos HTTP.
  Future<SenasaReportFileData> generateReport(
    SenasaReportRequestDto request,
  ) async {
    return _fileFrom(
      await _service.generateReport(request.toJson()),
      fallbackMediaType: 'application/octet-stream',
    );
  }

  /// Descarga los bytes originales de una exportación.
  Future<SenasaReportFileData> downloadGeneratedReport(String exportId) async {
    return _fileFrom(
      await _service.downloadGeneratedReport(exportId),
      fallbackMediaType: 'text/plain',
    );
  }

  Object? _dataFrom(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Invalid response envelope.');
      }
      return decoded['data'];
    } on FormatException {
      throw const SenasaReportException(
        message: 'La respuesta del servidor no es válida.',
      );
    }
  }

  SenasaExportHistoryItemDto _parseHistoryItem(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const SenasaReportException(
        message: 'Una exportación histórica no es válida.',
      );
    }
    try {
      return SenasaExportHistoryItemDto.fromJson(value);
    } on Object {
      throw const SenasaReportException(
        message: 'Una exportación histórica no es válida.',
      );
    }
  }

  Map<String, Object?> _normalizeValidation(Map<String, Object?> data) {
    return {
      'cantidad_exportable': data['cantidad_exportable'] ?? data['cantidadExportable'],
      'animales_incompletos': data['animales_incompletos'] ?? data['animalesIncompletos'],
    };
  }

  SenasaReportFileData _fileFrom(
    http.Response response, {
    required String fallbackMediaType,
  }) {
    return SenasaReportFileData(
      bytes: response.bodyBytes,
      filename: _filenameFrom(response.headers['content-disposition']) ?? 'declaracion_dispositivos.txt',
      mediaType: response.headers['content-type']?.split(';').first ?? fallbackMediaType,
    );
  }

  String? _filenameFrom(String? disposition) {
    return RegExp('filename="?([^";]+)').firstMatch(disposition ?? '')?.group(1);
  }
}
