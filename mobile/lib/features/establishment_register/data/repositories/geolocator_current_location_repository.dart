import 'dart:async';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/current_location_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

/// Lee la ubicación del dispositivo con el paquete `geolocator`.
///
/// Recibe la [GeolocatorPlatform] inyectada para poder probar cada rama
/// (GPS apagado, permiso negado, sin señal) sin un dispositivo real.
class GeolocatorCurrentLocationRepository implements CurrentLocationRepository {
  /// Crea el repositorio sobre la plataforma de geolocalización indicada.
  GeolocatorCurrentLocationRepository({GeolocatorPlatform? geolocator})
    : _geolocator = geolocator ?? GeolocatorPlatform.instance;

  /// Tiempo máximo para conseguir una posición antes de rendirse.
  ///
  /// El primer fix de un GPS en frío a cielo abierto suele tardar menos de 30 s.
  static const timeLimit = Duration(seconds: 30);

  static final _logger = Logger('GeolocatorCurrentLocationRepository');

  final GeolocatorPlatform _geolocator;

  @override
  Future<Result<CurrentLocation>> getCurrentLocation() async {
    if (!await _geolocator.isLocationServiceEnabled()) {
      return _failure(CurrentLocationFailure.serviceDisabled);
    }

    var permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        return _failure(CurrentLocationFailure.permissionDenied);
      case LocationPermission.deniedForever:
        return _failure(CurrentLocationFailure.permissionDeniedForever);
      case LocationPermission.whileInUse || LocationPermission.always || LocationPermission.unableToDetermine:
        break;
    }

    try {
      final position = await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: timeLimit),
      );
      return Result.success(
        CurrentLocation(
          latitud: position.latitude,
          longitud: position.longitude,
          precisionMetros: position.accuracy,
        ),
      );
    } on TimeoutException {
      return _failure(CurrentLocationFailure.timeout);
    } on LocationServiceDisabledException {
      return _failure(CurrentLocationFailure.serviceDisabled);
    } on PermissionDeniedException {
      return _failure(CurrentLocationFailure.permissionDenied);
    }
  }

  Result<CurrentLocation> _failure(CurrentLocationFailure reason) {
    _logger.warning('No se pudo leer la ubicación: ${reason.name}');
    return Result.failure(
      DomainException(
        message: 'No se pudo leer la ubicación (${reason.name}).',
        reason: reason,
      ),
    );
  }
}
