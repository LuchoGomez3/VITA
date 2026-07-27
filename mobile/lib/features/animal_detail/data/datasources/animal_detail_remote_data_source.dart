import 'dart:convert';

import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:http/http.dart' as http;

/// Data source HTTP para leer el detalle remoto de animales.
class AnimalDetailRemoteDataSource {
  /// Crea el data source con dependencias inyectables para runtime y tests.
  AnimalDetailRemoteDataSource({
    required BackendAccessTokenProvider tokenProvider,
    http.Client? client,
    String? backendBaseUrl,
  }) : _tokenProvider = tokenProvider,
       _client = client ?? http.Client(),
       _backendBaseUrl = backendBaseUrl ?? AppConfig.current.backendBaseUrl;

  final BackendAccessTokenProvider _tokenProvider;
  final http.Client _client;
  final String _backendBaseUrl;

  /// Solicita `GET /api/v1/animales/{id}` al backend.
  Future<AnimalDetailBackendDto> getAnimalById(String animalId) async {
    final token = await _tokenProvider.getAccessToken();
    if (token == null) {
      throw const DomainException(
        message: 'La sesión no está disponible para consultar el backend.',
        code: DomainErrorCode.unauthorized,
      );
    }

    final response = await _client.get(
      Uri.parse('$_backendBaseUrl/api/v1/animales/$animalId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw _invalidResponse();
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw _invalidResponse();
      }

      return AnimalDetailBackendDto.fromJson(data);
    }

    throw _errorFromResponse(response);
  }

  DomainException _invalidResponse() {
    return const DomainException(
      message: 'El backend devolvió una respuesta inválida para el animal.',
    );
  }

  DomainException _errorFromResponse(http.Response response) {
    if (response.statusCode == 401) {
      return const DomainException(
        message: 'La sesión no está autorizada para consultar este animal.',
        code: DomainErrorCode.unauthorized,
      );
    }

    if (response.statusCode == 404) {
      return const DomainException(
        message: 'No se encontró el animal solicitado.',
        code: DomainErrorCode.notFound,
      );
    }

    if (response.statusCode >= 500) {
      return const DomainException(
        message: 'No se pudo consultar el backend. Probá nuevamente más tarde.',
        code: DomainErrorCode.offline,
      );
    }

    return const DomainException(
      message: 'No se pudo cargar la información del animal.',
    );
  }
}

/// DTO del detalle remoto de animal devuelto por el backend.
class AnimalDetailBackendDto {
  /// Crea un DTO remoto de animal.
  const AnimalDetailBackendDto({
    required this.id,
    required this.establishmentId,
    required this.rfidTagNumber,
    required this.visualTag,
    required this.sex,
    required this.breed,
    required this.birthDate,
    required this.categoryId,
    required this.lotId,
    required this.motherId,
    required this.fatherId,
    required this.coat,
    required this.observations,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea el DTO desde el `data` del `StandardResponse`.
  factory AnimalDetailBackendDto.fromJson(Map<String, dynamic> json) {
    return AnimalDetailBackendDto(
      id: json['id'] as String,
      establishmentId: json['establecimiento_id'] as String,
      rfidTagNumber: json['nro_caravana_rfid'] as String? ?? '',
      visualTag: json['caravana_visual'] as String? ?? '',
      sex: json['sexo'] as String,
      breed: json['raza'] as String? ?? '',
      birthDate: DateTime.parse(json['fecha_nacimiento'] as String),
      categoryId: json['categoria_id'] as String? ?? '',
      lotId: json['lote_id'] as String? ?? '',
      motherId: json['madre_id'] as String?,
      fatherId: json['padre_id'] as String?,
      coat: json['pelaje'] as String?,
      observations: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// UUID backend/mobile.
  final String id;

  /// ID de establecimiento.
  final String establishmentId;

  /// Numero RFID.
  final String rfidTagNumber;

  /// Caravana visual.
  final String visualTag;

  /// Sexo en formato backend.
  final String sex;

  /// Raza.
  final String breed;

  /// Fecha de nacimiento.
  final DateTime birthDate;

  /// ID de categoria.
  final String categoryId;

  /// ID de lote.
  final String lotId;

  /// ID de madre.
  final String? motherId;

  /// ID de padre.
  final String? fatherId;

  /// Pelaje.
  final String? coat;

  /// Observaciones.
  final String? observations;

  /// Fecha de creacion.
  final DateTime createdAt;

  /// Fecha de actualizacion.
  final DateTime updatedAt;
}
