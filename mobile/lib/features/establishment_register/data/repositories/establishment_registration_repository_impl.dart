import 'dart:async';
import 'dart:io';

import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/data/datasources/establishment_registration_remote_data_source.dart';
import 'package:frontend_mayoral/features/establishment_register/data/mappers/establishment_registration_json_mapper.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';
import 'package:http/http.dart' as http;

/// Implementacion online-only del alta de establecimiento (mismo criterio de
/// manejo de errores que `AuthRepositoryImpl.register`).
class EstablishmentRegistrationRepositoryImpl implements EstablishmentRegistrationRepository {
  /// Crea el repositorio con la fuente remota inyectada.
  const EstablishmentRegistrationRepositoryImpl({
    required EstablishmentRegistrationRemoteDataSource remoteDataSource,
    required EstablishmentCatalog establishmentCatalog,
  }) : _remoteDataSource = remoteDataSource,
       _establishmentCatalog = establishmentCatalog;

  final EstablishmentRegistrationRemoteDataSource _remoteDataSource;
  final EstablishmentCatalog _establishmentCatalog;

  @override
  Future<Result<RegisteredEstablishment>> register(
    EstablishmentRegistration registration,
  ) async {
    try {
      final json = await _remoteDataSource.register(registration);
      final registered = EstablishmentRegistrationJsonMapper.registeredFromJson(
        json,
        registration,
      );
      await _establishmentCatalog.upsert(
        EstablishmentMembership(
          id: registered.id,
          name: registration.nombre,
          role: registered.role,
        ),
        metadata: {
          'owner_id': json['owner_id'],
          'renspa_number': registration.nroRenspa,
          'cuit': registration.cuitTitular,
          'area_hectares': registration.superficieHectareas,
          'province': registration.provincia,
          'department': registration.departamento,
          'locality': registration.localidad,
          'created_at': registered.createdAt.toUtc().toIso8601String(),
          'updated_at': json['updated_at'] is String
              ? json['updated_at']
              : registered.createdAt.toUtc().toIso8601String(),
        },
      );
      return Result.success(registered);
    } on DomainException catch (error) {
      return Result.failure(error);
    } on FormatException catch (error) {
      return Result.failure(DomainException(message: error.message));
    } on SocketException {
      return const Result.failure(
        DomainException(
          message: 'No se pudo conectar con el backend.',
          code: DomainErrorCode.offline,
        ),
      );
    } on TimeoutException {
      return const Result.failure(
        DomainException(
          message: 'El backend tardo demasiado en responder.',
          code: DomainErrorCode.offline,
        ),
      );
    } on http.ClientException {
      return const Result.failure(
        DomainException(
          message: 'No se pudo conectar con el backend.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }
}
