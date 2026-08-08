import 'dart:convert';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/exceptions/senasa_report_exception.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';
import 'package:http/http.dart' as http;

/// REST implementation of the SENASA report repository.
class SenasaReportRepositoryImpl implements SenasaReportRepository {
  /// Creates the repository.
  SenasaReportRepositoryImpl({
    required String baseUrl,
    required BackendAccessTokenProvider tokenProvider,
    required SecureStorageService secureStorage,
    http.Client? client,
  }) : _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
       _tokenProvider = tokenProvider,
       _secureStorage = secureStorage,
       _client = client ?? http.Client();

  final String _baseUrl;
  final BackendAccessTokenProvider _tokenProvider;
  final SecureStorageService _secureStorage;
  final http.Client _client;
  @override
  Future<List<SenasaExportHistoryItem>> getGeneratedReports(
    String establishmentId,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/v1/reportes/senasa/exportaciones').replace(
      queryParameters: {'establecimiento_id': establishmentId},
    );
    final payload = _decodeJson(await _get(uri));
    final data = payload['data'];
    if (data is! List<Object?>) {
      throw const SenasaReportException(
        message: 'El historial recibido no es válido.',
      );
    }
    return data.map(_mapHistoryItem).toList(growable: false);
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

  @override
  Future<List<SenasaEstablishment>> getEstablishments() async {
    try {
      final encoded = await _secureStorage.read(
        SecureStorageKeys.establishmentCatalog,
      );
      if (encoded == null || encoded.isEmpty) {
        return const [];
      }
      final catalog = jsonDecode(encoded);
      if (catalog is! List<Object?>) {
        throw const FormatException('Invalid establishment catalog.');
      }
      return catalog.map(_mapLocalEstablishment).toList(growable: false);
    } on Object {
      throw const SenasaReportException(
        message: 'No se pudieron leer los establecimientos guardados en el dispositivo.',
      );
    }
  }

  @override
  Future<GeneratedSenasaReport> generateReport(
    SenasaReportRequest request,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/api/v1/reportes/senasa/declaraciones_dispositivos',
    );
    final response = await _post(uri, _requestBody(request));
    return GeneratedSenasaReport(
      bytes: response.bodyBytes,
      filename: _filenameFrom(response.headers['content-disposition']) ?? 'declaracion_dispositivos.txt',
      mediaType: response.headers['content-type']?.split(';').first ?? 'application/octet-stream',
      generatedAt: DateTime.now(),
      animalCount: request.animalCount,
    );
  }

  @override
  Future<SenasaValidationResult> validateRecords(SenasaReportValidationRequest request) async {
    final uri = Uri.parse(
      '$_baseUrl/api/v1/reportes/senasa/declaraciones_dispositivos/validacion',
    );
    final response = await _post(uri, _validationRequestBody(request));
    final data = _decodeJson(response)['data'];
    if (data is! Map<String, Object?>) {
      throw const SenasaReportException(
        message: 'La validación recibida no es válida.',
      );
    }
    final exportable = data['cantidad_exportable'] ?? data['cantidadExportable'];
    final incomplete = data['animales_incompletos'] ?? data['animalesIncompletos'];
    if (exportable is! int || incomplete is! List<Object?>) {
      throw const SenasaReportException(
        message: 'La validación recibida no es válida.',
      );
    }
    return SenasaValidationResult(
      exportableAnimals: exportable,
      issues: incomplete.map(_mapRecordIssue).toList(growable: false),
    );
  }

  @override
  Future<GeneratedSenasaReport> downloadGeneratedReport(String exportId) async {
    final uri = Uri.parse(
      '$_baseUrl/api/v1/reportes/senasa/exportaciones/$exportId/descarga',
    );
    final response = await _get(uri);
    return GeneratedSenasaReport(
      bytes: response.bodyBytes,
      filename: _filenameFrom(response.headers['content-disposition']) ?? 'declaracion_dispositivos.txt',
      mediaType: response.headers['content-type']?.split(';').first ?? 'text/plain',
      generatedAt: DateTime.now(),
      animalCount: 0,
    );
  }

  Map<String, Object?> _requestBody(SenasaReportRequest request) {
    return {
      'establecimientoId': request.establishmentId,
      'desde': request.from.toUtc().toIso8601String(),
      'hasta': request.to.toUtc().toIso8601String(),
      'nombreArchivo': request.fileName,
    };
  }

  Map<String, Object?> _validationRequestBody(
    SenasaReportValidationRequest request,
  ) {
    return {
      'establecimientoId': request.establishmentId,
      'desde': request.from.toUtc().toIso8601String(),
      'hasta': request.to.toUtc().toIso8601String(),
      'nombreArchivo': request.fileName,
    };
  }

  SenasaRecordIssue _mapRecordIssue(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const SenasaReportException(message: 'Un animal incompleto no es válido.');
    }
    final missing = value['faltante'];
    return SenasaRecordIssue(
      animalId: (value['animal_id'] ?? value['animalId']) as String? ?? '',
      tag: value['caravana'] as String?,
      missingFields: missing is List<Object?> ? missing.whereType<String>().toList(growable: false) : const [],
    );
  }

  SenasaExportHistoryItem _mapHistoryItem(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const SenasaReportException(message: 'Una exportación histórica no es válida.');
    }
    final id = value['id'];
    final establishmentId = value['establecimiento_id'];
    final filename = value['nombre_archivo'];
    final mediaType = value['media_type'];
    final animalCount = value['cantidad_animales'];
    final generatedAt = value['created_at'];
    if (id is! String ||
        establishmentId is! String ||
        filename is! String ||
        mediaType is! String ||
        animalCount is! int ||
        generatedAt is! String) {
      throw const SenasaReportException(message: 'Una exportación histórica no es válida.');
    }
    return SenasaExportHistoryItem(
      id: id,
      establishmentId: establishmentId,
      filename: filename,
      mediaType: mediaType,
      animalCount: animalCount,
      generatedAt: DateTime.parse(generatedAt),
      from: _optionalDate(value['desde']),
      to: _optionalDate(value['hasta']),
    );
  }

  DateTime? _optionalDate(Object? value) {
    return value is String ? DateTime.parse(value) : null;
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await _client.get(uri, headers: await _headers());
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

  Future<http.Response> _post(Uri uri, Map<String, Object?> body) async {
    try {
      final response = await _client.post(
        uri,
        headers: {...await _headers(), 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw _exceptionFrom(response);
    } on SenasaReportException {
      rethrow;
    } on http.ClientException {
      throw const SenasaReportException(
        message: 'Necesitás conexión para validar, generar o recuperar archivos. El formulario conserva tus datos.',
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

  SenasaEstablishment _mapLocalEstablishment(Object? value) {
    if (value is! Map<String, Object?> || value['id'] is! String || value['name'] is! String) {
      throw const FormatException('Invalid local establishment.');
    }
    return SenasaEstablishment(
      id: value['id']! as String,
      name: value['name']! as String,
      renspa: value['renspa_number'] as String?,
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
