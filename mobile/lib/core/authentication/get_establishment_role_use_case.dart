import 'dart:async';

import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:logging/logging.dart';

/// Obtiene de forma segura el rol offline de un establecimiento concreto.
class GetEstablishmentRoleUseCase {
  /// Crea el caso de uso con el catalogo compartido.
  const GetEstablishmentRoleUseCase(this._catalog);

  final EstablishmentCatalog _catalog;
  static final Logger _logger = Logger('GetEstablishmentRoleUseCase');

  /// Devuelve `unknown` si el catalogo falta, esta corrupto o no contiene el ID.
  Future<UserRole> call(String establishmentId) async {
    try {
      final membership = await _catalog.getById(establishmentId);
      return membership?.role ?? UserRole.unknown;
    } on FormatException catch (error, stackTrace) {
      _logExpectedFailure(error, stackTrace);
      return UserRole.unknown;
    } on TimeoutException catch (error, stackTrace) {
      _logExpectedFailure(error, stackTrace);
      return UserRole.unknown;
    } on PlatformException catch (error, stackTrace) {
      _logExpectedFailure(error, stackTrace);
      return UserRole.unknown;
    }
  }

  void _logExpectedFailure(Object error, StackTrace stackTrace) {
    _logger.warning(
      'No se pudo leer el rol del catalogo offline.',
      error,
      stackTrace,
    );
  }
}
