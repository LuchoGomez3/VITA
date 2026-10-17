import 'dart:async';
import 'dart:convert';

import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/sync/data/models/establishment_remote_summary.dart';
import 'package:http/http.dart' as http;

/// Fuente remota liviana para obtener establecimientos antes del bootstrap.
class EstablishmentRemoteDataSource {
  /// Crea la fuente remota con cliente HTTP autenticado manualmente.
  const EstablishmentRemoteDataSource({
    required String backendBaseUrl,
    required BackendAccessTokenProvider tokenProvider,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 15),
  }) : _backendBaseUrl = backendBaseUrl,
       _tokenProvider = tokenProvider,
       _client = client,
       _requestTimeout = requestTimeout;

  final String _backendBaseUrl;
  final BackendAccessTokenProvider _tokenProvider;
  final http.Client _client;
  final Duration _requestTimeout;

  /// Obtiene todos los establecimientos disponibles para el usuario actual.
  Future<List<EstablishmentRemoteSummary>> fetchEstablishments() async {
    final token = await _tokenProvider.getAccessToken();
    if (token == null) {
      throw const DomainException(
        message: 'No hay token disponible para preparar los datos offline.',
        code: DomainErrorCode.unauthorized,
      );
    }

    final response = await _client
        .get(
          Uri.parse('$_backendBaseUrl/api/v1/establecimientos'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const DomainException(
        message: 'No se pudieron obtener los establecimientos.',
        code: DomainErrorCode.syncFailed,
      );
    }

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : decoded;

    if (data is! List) {
      return const [];
    }

    return data.whereType<Map<String, dynamic>>().map(EstablishmentRemoteSummary.fromJson).toList();
  }
}
