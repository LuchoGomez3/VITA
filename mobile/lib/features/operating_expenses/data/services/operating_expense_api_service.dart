import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_failure_messages.dart';
import 'package:http/http.dart' as http;

/// Transporte autenticado para consultas financieras de solo lectura.
class OperatingExpenseApiService {
  /// Crea el servicio sobre la configuracion y sesion compartidas.
  OperatingExpenseApiService({
    required String baseUrl,
    required SessionBackendAccessTokenProvider tokenProvider,
    http.Client? client,
    Duration timeout = const Duration(seconds: 15),
  }) : _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
       _tokenProvider = tokenProvider,
       _client = client ?? http.Client(),
       _timeout = timeout;

  final String _baseUrl;
  final SessionBackendAccessTokenProvider _tokenProvider;
  final http.Client _client;
  final Duration _timeout;

  /// Consulta egresos con los filtros activos e incluye tombstones para sync.
  Future<http.Response> getExpenses(String establishmentId, OperatingExpenseFilters filters) =>
      _get(_uri('/api/v1/egresos_operativos', establishmentId, filters, includeDeleted: true));

  /// Consulta el catalogo central del establecimiento.
  Future<http.Response> getCatalog(String establishmentId) => _get(
    Uri.parse('$_baseUrl/api/v1/egresos_operativos/catalogo').replace(
      queryParameters: {'establecimiento_id': establishmentId},
    ),
  );

  /// Descarga el CSV con exactamente los mismos filtros visibles.
  Future<http.Response> exportExpenses(String establishmentId, OperatingExpenseFilters filters) =>
      _get(_uri('/api/v1/egresos_operativos/exportar', establishmentId, filters));

  /// Construye los parametros del contrato sin filtrar valores vacios.
  static Map<String, String> queryParameters(
    String establishmentId,
    OperatingExpenseFilters filters, {
    bool includeDeleted = false,
  }) {
    String date(DateTime value) =>
        '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    return {
      'establecimiento_id': establishmentId,
      if (filters.from case final from?) 'fecha_desde': date(from),
      if (filters.to case final to?) 'fecha_hasta': date(to),
      if (filters.type case final type?) 'tipo': type.value,
      if (filters.category case final category?) 'categoria': category,
      if (includeDeleted) 'include_deleted': 'true',
    };
  }

  Uri _uri(
    String path,
    String establishmentId,
    OperatingExpenseFilters filters, {
    bool includeDeleted = false,
  }) => Uri.parse('$_baseUrl$path').replace(
    queryParameters: queryParameters(
      establishmentId,
      filters,
      includeDeleted: includeDeleted,
    ),
  );

  Future<http.Response> _get(Uri uri) async {
    try {
      final first = await _send(uri, await _tokenProvider.getAccessToken());
      if (first.statusCode != 401) return _ensureSuccessful(first);
      final refreshedToken = await _tokenProvider.refreshAccessToken();
      if (refreshedToken == null) {
        throw const DomainException(
          message: OperatingExpenseFailureMessages.sessionExpired,
          code: DomainErrorCode.unauthorized,
        );
      }
      return _ensureSuccessful(await _send(uri, refreshedToken));
    } on DomainException {
      rethrow;
    } on SocketException {
      throw const DomainException(
        message: OperatingExpenseFailureMessages.offline,
        code: DomainErrorCode.offline,
      );
    } on TimeoutException {
      throw const DomainException(
        message: OperatingExpenseFailureMessages.offline,
        code: DomainErrorCode.offline,
      );
    } on http.ClientException {
      throw const DomainException(
        message: OperatingExpenseFailureMessages.offline,
        code: DomainErrorCode.offline,
      );
    }
  }

  Future<http.Response> _send(Uri uri, String? token) {
    if (token == null || token.isEmpty) {
      throw const DomainException(
        message: OperatingExpenseFailureMessages.sessionExpired,
        code: DomainErrorCode.unauthorized,
      );
    }
    return _client.get(uri, headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
  }

  http.Response _ensureSuccessful(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return response;
    final code = _errorCode(response);
    if (response.statusCode == 403 && code == 'acceso_financiero_denegado') {
      throw const DomainException(
        message: OperatingExpenseFailureMessages.accessDenied,
        code: DomainErrorCode.validation,
        reason: OperatingExpensePersistenceError.financialAccessDenied,
      );
    }
    if (response.statusCode == 401) {
      throw const DomainException(
        message: OperatingExpenseFailureMessages.sessionExpired,
        code: DomainErrorCode.unauthorized,
      );
    }
    throw DomainException(
      message: _errorMessage(response) ?? OperatingExpenseFailureMessages.remote,
      code: DomainErrorCode.syncFailed,
    );
  }

  String? _errorCode(http.Response response) => _firstErrorValue(response, 'code');

  String? _errorMessage(http.Response response) => _firstErrorValue(response, 'message');

  String? _firstErrorValue(http.Response response, String key) {
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is! Map<String, dynamic>) return null;
      final errors = payload['errors'];
      if (errors is! List || errors.isEmpty || errors.first is! Map<String, dynamic>) return null;
      return (errors.first as Map<String, dynamic>)[key] as String?;
    } on FormatException {
      return null;
    }
  }
}
