import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:http/http.dart' as http;

/// Color y fecha de la última foto, tal como los tiene la cuenta.
typedef RemoteProfileAppearance = ({String? headerColor, DateTime? avatarUpdatedAt});

/// Endpoints del perfil propio: color de la cabecera y foto.
///
/// La foto va en su propio request multipart porque la cola offline de Brick
/// no encola archivos: el repositorio guarda lo pendiente y lo reintenta.
class ProfileAppearanceRemoteDataSource {
  /// Crea el data source contra [baseUrl].
  ProfileAppearanceRemoteDataSource({
    required String baseUrl,
    required BackendAccessTokenProvider tokenProvider,
    http.Client? client,
  }) : _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
       _tokenProvider = tokenProvider,
       _client = client ?? http.Client();

  /// Una foto de 1 MB por una conexión rural lenta entra con margen.
  static const _timeout = Duration(seconds: 30);

  final String _baseUrl;
  final BackendAccessTokenProvider _tokenProvider;
  final http.Client _client;

  Uri get _me => Uri.parse('$_baseUrl/api/v1/usuarios/me');

  Uri get _avatar => Uri.parse('$_baseUrl/api/v1/usuarios/me/avatar');

  /// Lee el color y la fecha de la foto de la cuenta.
  Future<RemoteProfileAppearance> fetch() async {
    final response = await _send(
      () async => _client.get(Uri.parse('$_baseUrl/api/auth/me'), headers: await _headers()),
    );
    return _appearanceFrom(response);
  }

  /// Guarda [hexColor] (`#RRGGBB`) en la cuenta; `null` vuelve al original.
  Future<RemoteProfileAppearance> updateHeaderColor(String? hexColor) async {
    final response = await _send(
      () async => _client.patch(
        _me,
        headers: {...await _headers(), 'Content-Type': 'application/json'},
        body: jsonEncode({'color_cabecera': hexColor}),
      ),
    );
    return _appearanceFrom(response);
  }

  /// Sube [jpeg] como la foto del usuario (el backend la achica y reemplaza
  /// la anterior).
  Future<RemoteProfileAppearance> uploadAvatar(Uint8List jpeg) async {
    final response = await _send(() async {
      final request = http.MultipartRequest('PUT', _avatar)
        ..headers.addAll(await _headers())
        ..files.add(http.MultipartFile.fromBytes('archivo', jpeg, filename: 'avatar.jpg'));
      return http.Response.fromStream(await _client.send(request));
    });
    return _appearanceFrom(response);
  }

  /// Baja la foto de la cuenta; `null` si no tiene.
  Future<Uint8List?> downloadAvatar() async {
    try {
      final response = await _send(() async => _client.get(_avatar, headers: await _headers()));
      return response.bodyBytes;
    } on DomainException catch (error) {
      if (error.code == DomainErrorCode.notFound) {
        return null;
      }
      rethrow;
    }
  }

  /// Borra la foto de la cuenta.
  Future<RemoteProfileAppearance> deleteAvatar() async {
    final response = await _send(() async => _client.delete(_avatar, headers: await _headers()));
    return _appearanceFrom(response);
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
    throw DomainException(
      message: _backendMessage(response) ?? 'El servidor no pudo guardar el cambio (${response.statusCode}).',
      code: switch (response.statusCode) {
        401 => DomainErrorCode.unauthorized,
        404 => DomainErrorCode.notFound,
        413 || 422 => DomainErrorCode.validation,
        _ => DomainErrorCode.unknown,
      },
    );
  }

  static const _offline = DomainException(
    message: 'Sin conexión: el cambio queda guardado en el celular y se sube cuando vuelva la señal.',
    code: DomainErrorCode.offline,
  );

  RemoteProfileAppearance _appearanceFrom(http.Response response) {
    final payload = jsonDecode(utf8.decode(response.bodyBytes));
    final data = payload is Map<String, dynamic> ? payload['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Respuesta de perfil sin datos.');
    }
    final updatedAt = data['avatar_actualizado_en'];
    return (
      headerColor: data['color_cabecera'] as String?,
      avatarUpdatedAt: updatedAt is String ? DateTime.parse(updatedAt) : null,
    );
  }

  String? _backendMessage(http.Response response) {
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      final errors = payload is Map<String, dynamic> ? payload['errors'] : null;
      if (errors is List && errors.isNotEmpty && errors.first is Map<String, dynamic>) {
        return (errors.first as Map<String, dynamic>)['message'] as String?;
      }
      final detail = payload is Map<String, dynamic> ? payload['detail'] : null;
      return detail is String ? detail : null;
    } on FormatException {
      return null;
    }
  }
}
