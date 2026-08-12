import 'dart:convert';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';
import 'package:http/http.dart' as http;

/// Encapsula el transporte HTTP autenticado de los endpoints SENASA.
class SenasaReportApiService {
  /// Crea el servicio que se comunica con el backend configurado.
  SenasaReportApiService({
    required String baseUrl,
    required BackendAccessTokenProvider tokenProvider,
    http.Client? client,
  }) : _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
       _tokenProvider = tokenProvider,
       _client = client ?? http.Client();

  final String _baseUrl;
  final BackendAccessTokenProvider _tokenProvider;
  final http.Client _client;

  /// Consulta las exportaciones del establecimiento seleccionado.
  Future<http.Response> getGeneratedReports(String establishmentId) {
    final uri = Uri.parse('$_baseUrl/api/v1/reportes/senasa/exportaciones').replace(
      queryParameters: {'establecimiento_id': establishmentId},
    );
    return _get(uri);
  }

  /// Solicita al backend la validación de los registros seleccionados.
  Future<http.Response> validateRecords(Map<String, Object?> body) {
    return _post(
      Uri.parse('$_baseUrl/api/v1/reportes/senasa/declaraciones_dispositivos/validacion'),
      body,
    );
  }

  /// Genera y descarga una nueva declaración SENASA.
  Future<http.Response> generateReport(Map<String, Object?> body) {
    return _post(
      Uri.parse('$_baseUrl/api/v1/reportes/senasa/declaraciones_dispositivos'),
      body,
    );
  }

  /// Descarga una exportación histórica sin recalcularla.
  Future<http.Response> downloadGeneratedReport(String exportId) {
    return _get(
      Uri.parse('$_baseUrl/api/v1/reportes/senasa/exportaciones/$exportId/descarga'),
    );
  }

  Future<Map<String, String>> _headers() async {
    final accessToken = await _tokenProvider.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const SenasaReportException(
        message: 'No hay una sesión autenticada para consultar SENASA.',
        code: DomainErrorCode.unauthorized,
      );
    }
    return {'Authorization': 'Bearer $accessToken'};
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      return _ensureSuccessful(
        await _client.get(uri, headers: await _headers()),
      );
    } on SenasaReportException {
      rethrow;
    } on http.ClientException {
      throw const SenasaReportException(
        message: 'No se pudo conectar con el servidor. Verificá tu conexión.',
        code: DomainErrorCode.offline,
      );
    }
  }

  Future<http.Response> _post(Uri uri, Map<String, Object?> body) async {
    try {
      return _ensureSuccessful(
        await _client.post(
          uri,
          headers: {...await _headers(), 'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ),
      );
    } on SenasaReportException {
      rethrow;
    } on http.ClientException {
      throw const SenasaReportException(
        message: 'Necesitás conexión para validar, generar o recuperar archivos. El formulario conserva tus datos.',
        code: DomainErrorCode.offline,
      );
    }
  }

  http.Response _ensureSuccessful(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    throw _exceptionFrom(response);
  }

  SenasaReportException _exceptionFrom(http.Response response) {
    if (response.statusCode == 401) {
      return const SenasaReportException(
        message: 'Tu sesión venció. Volvé a iniciar sesión.',
        code: DomainErrorCode.unauthorized,
      );
    }

    final message = _backendErrorMessage(response);
    return SenasaReportException(
      message: message ?? 'El servidor no pudo completar la solicitud (${response.statusCode}).',
      code: response.statusCode == 422 ? DomainErrorCode.validation : DomainErrorCode.unknown,
    );
  }

  String? _backendErrorMessage(http.Response response) {
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is! Map<String, Object?>) {
        return null;
      }
      final errors = payload['errors'];
      if (errors is! List<Object?> || errors.isEmpty) {
        return null;
      }
      final first = errors.first;
      return first is Map<String, Object?> ? first['message'] as String? : null;
    } on FormatException {
      return null;
    }
  }
}
