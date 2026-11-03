import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/team/data/team_json.dart';
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
    bool Function()? isSessionCurrent,
  }) : _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
       _tokenProvider = tokenProvider,
       _client = client,
       _isSessionCurrent = isSessionCurrent ?? (() => true);

  /// Invitar espera el envío del email (hasta 10 s del lado del servidor).
  static const _timeout = Duration(seconds: 20);

  final String _baseUrl;
  final BackendAccessTokenProvider _tokenProvider;
  final http.Client? _client;
  final bool Function() _isSessionCurrent;

  void _requireSession() {
    if (!_isSessionCurrent()) {
      throw const DomainException(message: 'Session changed', code: DomainErrorCode.unauthorized);
    }
  }

  Uri _establishment(String id, String path) => Uri.parse('$_baseUrl/api/v1/establecimientos/$id/$path');

  Uri _invitations(String path) => Uri.parse('$_baseUrl/api/v1/invitaciones/$path');

  /// Miembros activos del equipo.
  Future<List<TeamMember>> fetchMembers(String establishmentId) async {
    final response = await _send(
      (client) async => client.get(_establishment(establishmentId, 'usuarios'), headers: await _headers()),
    );
    return [for (final json in _dataList(response)) _memberFrom(json)];
  }

  /// Invitaciones pendientes (incluidas las vencidas).
  Future<List<TeamInvitation>> fetchInvitations(String establishmentId) async {
    final response = await _send(
      (client) async => client.get(_establishment(establishmentId, 'invitaciones'), headers: await _headers()),
    );
    return [for (final json in _dataList(response)) _invitationFrom(json)];
  }

  /// Crea una invitación y manda el email.
  Future<CreatedInvitation> invite(String establishmentId, {required String email, required UserRole role}) async {
    final response = await _send(
      (client) async => client.post(
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
      (client) async => client.post(
        _establishment(establishmentId, 'invitaciones/$invitationId/reenvios'),
        headers: await _headers(),
      ),
    );
    return _createdFrom(_data(response));
  }

  /// Cancela una invitación pendiente.
  Future<void> cancel(String establishmentId, String invitationId) async {
    await _send(
      (client) async => client.delete(
        _establishment(establishmentId, 'invitaciones/$invitationId'),
        headers: await _headers(),
      ),
    );
  }

  /// Quita a una persona del equipo.
  Future<void> removeMember(String establishmentId, String userId) async {
    await _send(
      (client) async => client.delete(_establishment(establishmentId, 'usuarios/$userId'), headers: await _headers()),
    );
  }

  /// Previsualiza el código sin consumirlo.
  Future<InvitationPreview> preview(String code) async {
    final response = await _send(
      (client) async => client.post(
        _invitations('validaciones'),
        headers: await _jsonHeaders(),
        body: jsonEncode({'codigo': code}),
      ),
    );
    final json = _data(response);
    final invitedByRole = teamOptionalString(json, 'invitado_por_rol');
    return (
      establishmentId: teamString(json, 'establecimiento_id'),
      establishmentName: teamString(json, 'establecimiento_nombre'),
      renspa: teamOptionalString(json, 'establecimiento_renspa'),
      locality: teamOptionalString(json, 'establecimiento_localidad'),
      province: teamOptionalString(json, 'establecimiento_provincia'),
      role: UserRolePermissions.fromBackend(teamOptionalString(json, 'rol')),
      email: (teamOptionalString(json, 'email')) ?? '',
      invitedBy: (teamOptionalString(json, 'invitado_por')) ?? '',
      invitedByRole: invitedByRole == null ? null : UserRolePermissions.fromBackend(invitedByRole),
      expiresAt: DateTime.parse(teamString(json, 'expira_en')),
    );
  }

  /// Canjea el código; devuelve el establecimiento con el mismo formato que
  /// `GET /establecimientos`.
  Future<Map<String, dynamic>> accept(String code) async {
    final response = await _acceptRequest(code);
    try {
      return _data(response);
    } on FormatException {
      throw teamError(TeamErrorReason.acceptanceNeedsRecovery);
    }
  }

  Future<http.Response> _acceptRequest(String code) async {
    try {
      return await _send(
        (client) async => client.post(
          _invitations('aceptaciones'),
          headers: await _jsonHeaders(),
          body: jsonEncode({'codigo': code}),
        ),
      );
    } on DomainException catch (error) {
      if (error.code == DomainErrorCode.offline) {
        throw teamError(TeamErrorReason.acceptanceNeedsRecovery);
      }
      rethrow;
    }
  }

  Future<Map<String, String>> _headers() async {
    _requireSession();
    final accessToken = await _tokenProvider.getAccessToken();
    _requireSession();
    if (accessToken == null || accessToken.isEmpty) {
      throw const DomainException(
        message: 'Missing authenticated session',
        code: DomainErrorCode.unauthorized,
      );
    }
    return {'Authorization': 'Bearer $accessToken'};
  }

  Future<Map<String, String>> _jsonHeaders() async => {...await _headers(), 'Content-Type': 'application/json'};

  Future<http.Response> _send(Future<http.Response> Function(http.Client) request) async {
    final http.Response response;
    final client = _client ?? http.Client();
    try {
      response = await request(client).timeout(_timeout);
    } on SocketException {
      throw _offline;
    } on http.ClientException {
      throw _offline;
    } on TimeoutException {
      throw _offline;
    } finally {
      if (_client == null) client.close();
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _requireSession();
      return response;
    }
    final (backendCode, remaining) = _backendError(response);
    throw DomainException(
      message: 'Team HTTP request failed: ${response.statusCode}',
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
    message: 'Team transport unavailable',
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
    return teamObjects(data);
  }

  static TeamMember _memberFrom(Map<String, dynamic> json) => (
    userId: teamString(json, 'usuario_id'),
    firstName: teamString(json, 'nombre'),
    lastName: teamString(json, 'apellido'),
    email: teamString(json, 'email'),
    role: UserRolePermissions.fromBackend(teamOptionalString(json, 'rol')),
    isHolder: json['es_titular'] == true,
    headerColor: teamOptionalString(json, 'color_cabecera'),
    memberSince: DateTime.parse(teamString(json, 'miembro_desde')),
  );

  static CreatedInvitation _createdFrom(Map<String, dynamic> json) =>
      (invitation: _invitationFrom(json), code: teamString(json, 'codigo'));

  static TeamInvitation _invitationFrom(Map<String, dynamic> json) => (
    id: teamString(json, 'id'),
    email: teamString(json, 'email'),
    role: UserRolePermissions.fromBackend(teamOptionalString(json, 'rol')),
    expiresAt: DateTime.parse(teamString(json, 'expira_en')),
    isExpired: json['vencida'] == true,
    emailSent: json['email_enviado'] == true,
    createdAt: DateTime.parse(teamString(json, 'created_at')),
  );

  (String?, int?) _backendError(http.Response response) {
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload case {'errors': [final Map<String, dynamic> error, ...]}) {
        final details = error['details'];
        final remaining = details is Map<String, dynamic> ? details['intentos_restantes'] : null;
        return (teamOptionalString(error, 'code'), remaining is int ? remaining : null);
      }
      return (null, null);
    } on FormatException {
      return (null, null);
    }
  }
}
