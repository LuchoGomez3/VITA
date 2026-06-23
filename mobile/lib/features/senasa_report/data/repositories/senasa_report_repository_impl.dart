import 'dart:convert';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';
import 'package:http/http.dart' as http;

/// REST implementation of the SENASA report repository.
class SenasaReportRepositoryImpl implements SenasaReportRepository {
  /// Creates the repository.
  SenasaReportRepositoryImpl({
    required String baseUrl,
    required String accessToken,
    http.Client? client,
  }) : _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
       _accessToken = accessToken,
       _client = client ?? http.Client();

  final String _baseUrl;
  final String _accessToken;
  final http.Client _client;

  Map<String, String> get _headers {
    if (_accessToken.isEmpty) {
      throw const SenasaReportException(
        message: 'No hay una sesión autenticada para consultar SENASA.',
        code: DomainErrorCode.unauthorized,
      );
    }
    return {'Authorization': 'Bearer $_accessToken'};
  }

  @override
  Future<List<SenasaEstablishment>> getEstablishments() async {
    final response = await _get(Uri.parse('$_baseUrl/v1/establecimientos'));
    final payload = _decodeJson(response);
    final data = payload['data'];
    if (data is! List<Object?>) {
      throw const SenasaReportException(message: 'La respuesta de establecimientos no es válida.');
    }
    return data.map(_mapEstablishment).toList(growable: false);
  }

  @override
  Future<GeneratedSenasaReport> generateReport(
    SenasaReportRequest request,
  ) async {
    final uri = Uri.parse('$_baseUrl/v1/reportes/senasa').replace(
      queryParameters: {
        'establecimiento_id': request.establishmentId,
        'formato': request.format,
        'desde': request.from.toUtc().toIso8601String(),
        'hasta': request.to.toUtc().toIso8601String(),
        'tipo_evento': request.eventType,
        'incluir_responsable': 'true',
        'responsable_nombre': request.responsibleName,
        'responsable_dni': request.responsibleDni,
      },
    );
    final response = await _get(uri);
    final filename = _filenameFrom(response.headers['content-disposition']) ?? 'reporte_senasa.${request.format}';
    return GeneratedSenasaReport(
      bytes: response.bodyBytes,
      filename: filename,
      mediaType: response.headers['content-type']?.split(';').first ?? 'application/octet-stream',
    );
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw _exceptionFrom(response);
    } on SenasaReportException {
      rethrow;
    } on http.ClientException {
      throw const SenasaReportException(
        message: 'No se pudo conectar con el servidor. Verificá tu conexión.',
        code: DomainErrorCode.offline,
      );
    }
  }

  Map<String, Object?> _decodeJson(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, Object?>) {
      throw const SenasaReportException(message: 'La respuesta del servidor no es válida.');
    }
    return decoded;
  }

  SenasaEstablishment _mapEstablishment(Object? value) {
    if (value is! Map<String, Object?> || value['id'] is! String || value['nombre'] is! String) {
      throw const SenasaReportException(message: 'Un establecimiento recibido no es válido.');
    }
    return SenasaEstablishment(
      id: value['id']! as String,
      name: value['nombre']! as String,
      renspa: value['nro_renspa'] as String?,
    );
  }

  SenasaReportException _exceptionFrom(http.Response response) {
    if (response.statusCode == 401) {
      return const SenasaReportException(
        message: 'Tu sesión venció. Volvé a iniciar sesión.',
        code: DomainErrorCode.unauthorized,
      );
    }
    try {
      final payload = _decodeJson(response);
      final errors = payload['errors'];
      if (errors is List<Object?> && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map<String, Object?> && first['message'] is String) {
          return SenasaReportException(
            message: first['message']! as String,
            code: response.statusCode == 422 ? DomainErrorCode.validation : DomainErrorCode.unknown,
          );
        }
      }
    } on FormatException {
      // The fallback below handles non-JSON server responses.
    }
    return SenasaReportException(
      message: 'El servidor no pudo completar la solicitud (${response.statusCode}).',
    );
  }

  String? _filenameFrom(String? disposition) {
    final match = RegExp('filename="?([^";]+)').firstMatch(disposition ?? '');
    return match?.group(1);
  }
}
