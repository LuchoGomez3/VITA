import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:http/http.dart' as http;

/// Endpoints del equipo de un establecimiento (adr-0012).
class TeamRemoteDataSource {
  /// Crea el data source contra [baseUrl].
  TeamRemoteDataSource({
    required String baseUrl,
    required BackendAccessTokenProvider tokenProvider,
    http.Client? client,
  }) : _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
       _tokenProvider = tokenProvider,
       _client = client ?? http.Client();

  /// Invitar espera el envío del email (hasta 10 s del lado del servidor).
  static const _timeout = Duration(seconds: 20);

  final String _baseUrl;
  final BackendAccessTokenProvider _tokenProvider;
  final http.Client _client;

  Uri _establishment(String id, String path) => Uri.parse('$_baseUrl/api/v1/establecimientos/$id/$path');

  Uri _invitations(String path) => Uri.parse('$_baseUrl/api/v1/invitaciones/$path');

  /// Miembros activos del equipo.
  Future<List<TeamMember>> fetchMembers(String establishmentId) async {
    final response = await _send(
      () async => _client.get(_establishment(establishmentId, 'usuarios'), headers: await _headers()),
    );
    return [for (final json in _dataList(response)) _memberFrom(json)];
  }

  /// Invitaciones pendientes (incluidas las vencidas).
  Future<List<TeamInvitation>> fetchInvitations(String establishmentId) async {
    final response = await _send(
      () async => _client.get(_establishment(establishmentId, 'invitaciones'), headers: await _headers()),
    );
    return [for (final json in _dataList(response)) _invitationFrom(json)];
  }

  /// Crea una invitación y manda el email.
  Future<CreatedInvitation> invite(String establishmentId, {required String email, required UserRole role}) async {
    final response = await _send(
      () async => _client.post(
        _establishment(establishmentId, 'invitaciones'),
        headers: await _jsonHeaders(),
        body: jsonEncode({'email': email, 'rol': role.backendValue}),
      ),
    );
    return _createdFrom(_data(response));
  }

  /// Genera un código nuevo y reenvía el email.
  Future<CreatedInvitation> resend(String establishmentId, String invitationId) async {
    final response = await _send(
      () async => _client.post(
        _establishment(establishmentId, 'invitaciones/$invitationId/reenvios'),
        headers: await _headers(),
      ),
    );
    return _createdFrom(_data(response));
  }

  /// Cancela una invitación pendiente.
  Future<void> cancel(String establishmentId, String invitationId) async {
    await _send(
      () async => _client.delete(
        _establishment(establishmentId, 'invitaciones/$invitationId'),
        headers: await _headers(),
      ),
    );
  }

  /// Quita a una persona del equipo.
  Future<void> removeMember(String establishmentId, String userId) async {
    await _send(
      () async => _client.delete(_establishment(establishmentId, 'usuarios/$userId'), headers: await _headers()),
    );
  }

  /// Previsualiza el código sin consumirlo.
  Future<InvitationPreview> preview(String code) async {
    final response = await _send(
      () async => _client.post(
        _invitations('validaciones'),
        headers: await _jsonHeaders(),
        body: jsonEncode({'codigo': code}),
      ),
    );
    final json = _data(response);
    final invitedByRole = json['invitado_por_rol'] as String?;
    return (
      establishmentId: json['establecimiento_id'] as String,
      establishmentName: json['establecimiento_nombre'] as String,
      renspa: json['establecimiento_renspa'] as String?,
      locality: json['establecimiento_localidad'] as String?,
      province: json['establecimiento_provincia'] as String?,
      role: UserRolePermissions.fromBackend(json['rol'] as String?),
      email: (json['email'] as String?) ?? '',
      invitedBy: (json['invitado_por'] as String?) ?? '',
      invitedByRole: invitedByRole == null ? null : UserRolePermissions.fromBackend(invitedByRole),
      expiresAt: DateTime.parse(json['expira_en'] as String),
    );
  }

  /// Canjea el código; devuelve el establecimiento con el mismo formato que
  /// `GET /establecimientos`.
  Future<Map<String, dynamic>> accept(String code) async {
    final response = await _send(
      () async => _client.post(
        _invitations('aceptaciones'),
        headers: await _jsonHeaders(),
        body: jsonEncode({'codigo': code}),
      ),
    );
    return _data(response);
  }

  Future<Map<String, String>> _headers() async {
    final accessToken = await _tokenProvider.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const DomainException(
        message: 'No hay una sesión iniciada.',
        code: DomainErrorCode.unauthorized,
      );
    }
    return {'Authorization': 'Bearer $accessToken'};
  }

  Future<Map<String, String>> _jsonHeaders() async => {...await _headers(), 'Content-Type': 'application/json'};

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on SocketException {
      throw _offline;
    } on http.ClientException {
      throw _offline;
    } on TimeoutException {
      throw _offline;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    final (message, backendCode, remaining) = _backendError(response);
    throw DomainException(
      message: message ?? 'El servidor no pudo completar la operación (${response.statusCode}).',
      code: switch (response.statusCode) {
        401 => DomainErrorCode.unauthorized,
        404 => DomainErrorCode.notFound,
        409 => DomainErrorCode.conflict,
        422 => DomainErrorCode.validation,
        _ => DomainErrorCode.unknown,
      },
      reason: (
        reason: response.statusCode == 429
            ? TeamErrorReason.tooManyAttempts
            : TeamErrorReason.fromBackendCode(backendCode),
        remainingAttempts: response.statusCode == 429 ? 0 : remaining,
      ),
    );
  }

  static const _offline = DomainException(
    message: 'Sin conexión: para gestionar el equipo hace falta señal.',
    code: DomainErrorCode.offline,
  );

  Map<String, dynamic> _data(http.Response response) {
    final payload = jsonDecode(utf8.decode(response.bodyBytes));
    final data = payload is Map<String, dynamic> ? payload['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Respuesta del equipo sin datos.');
    }
    return data;
  }

  List<Map<String, dynamic>> _dataList(http.Response response) {
    final payload = jsonDecode(utf8.decode(response.bodyBytes));
    final data = payload is Map<String, dynamic> ? payload['data'] : null;
    if (data is! List) {
      throw const FormatException('Respuesta del equipo sin datos.');
    }
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static TeamMember _memberFrom(Map<String, dynamic> json) => (
    userId: json['usuario_id'] as String,
    firstName: json['nombre'] as String,
    lastName: json['apellido'] as String,
    email: json['email'] as String,
    role: UserRolePermissions.fromBackend(json['rol'] as String?),
    isHolder: json['es_titular'] == true,
    headerColor: json['color_cabecera'] as String?,
    memberSince: DateTime.parse(json['miembro_desde'] as String),
  );

  static CreatedInvitation _createdFrom(Map<String, dynamic> json) =>
      (invitation: _invitationFrom(json), code: json['codigo'] as String);

  static TeamInvitation _invitationFrom(Map<String, dynamic> json) => (
    id: json['id'] as String,
    email: json['email'] as String,
    role: UserRolePermissions.fromBackend(json['rol'] as String?),
    expiresAt: DateTime.parse(json['expira_en'] as String),
    isExpired: json['vencida'] == true,
    emailSent: json['email_enviado'] == true,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  (String?, String?, int?) _backendError(http.Response response) {
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      final errors = payload is Map<String, dynamic> ? payload['errors'] : null;
      if (errors is List && errors.isNotEmpty && errors.first is Map<String, dynamic>) {
        final error = errors.first as Map<String, dynamic>;
        final details = error['details'];
        final remaining = details is Map<String, dynamic> ? details['intentos_restantes'] : null;
        return (error['message'] as String?, error['code'] as String?, remaining is int ? remaining : null);
      }
      // Los HTTPException (p. ej. el 429 del límite de intentos) llegan como
      // `{"error": "..."}`.
      final error = payload is Map<String, dynamic> ? payload['error'] : null;
      return (error is String ? error : null, null, null);
    } on FormatException {
      return (null, null, null);
    }
  }
}
