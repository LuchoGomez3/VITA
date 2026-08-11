import 'dart:async';
import 'dart:io';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/data/mappers/establishment_registration_json_mapper.dart';
import 'package:frontend_mayoral/features/establishment_register/data/sources/establishment_registration_remote_data_source.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/establishment_registration_repository.dart';
import 'package:http/http.dart' as http;

/// Implementacion online-only del alta de establecimiento (mismo criterio de
/// manejo de errores que `AuthRepositoryImpl.register`).
class EstablishmentRegistrationRepositoryImpl implements EstablishmentRegistrationRepository {
  /// Crea el repositorio con la fuente remota inyectada.
  const EstablishmentRegistrationRepositoryImpl({
    required EstablishmentRegistrationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final EstablishmentRegistrationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<RegisteredEstablishment>> register(
    EstablishmentRegistration registration,
  ) async {
    try {
      final json = await _remoteDataSource.register(registration);
      return Result.success(
        EstablishmentRegistrationJsonMapper.registeredFromJson(json, registration),
      );
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
