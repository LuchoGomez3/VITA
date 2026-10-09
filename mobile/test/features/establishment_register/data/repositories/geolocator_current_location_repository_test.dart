import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/data/repositories/geolocator_current_location_repository.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group('GeolocatorCurrentLocationRepository', () {
    late _FakeGeolocatorPlatform geolocator;
    late GeolocatorCurrentLocationRepository repository;

    setUp(() {
      geolocator = _FakeGeolocatorPlatform();
      repository = GeolocatorCurrentLocationRepository(geolocator: geolocator);
    });

    test('returns the GPS position with its accuracy', () async {
      final result = await repository.getCurrentLocation();

      expect(
        result,
        const Result<CurrentLocation>.success(
          CurrentLocation(latitud: -32.1234, longitud: -63.5678, precisionMetros: 6),
        ),
      );
      expect(geolocator.requestedTimeLimit, GeolocatorCurrentLocationRepository.timeLimit);
    });

    test('fails without asking permission when the GPS is off', () async {
      geolocator.serviceEnabled = false;

      final result = await repository.getCurrentLocation();

      expect(_reasonOf(result), CurrentLocationFailure.serviceDisabled);
      expect(geolocator.permissionRequests, 0);
    });

    test('asks for permission and reads the position once granted', () async {
      geolocator
        ..permission = LocationPermission.denied
        ..permissionAfterRequest = LocationPermission.whileInUse;

      final result = await repository.getCurrentLocation();

      expect(result, isA<Success<CurrentLocation>>());
      expect(geolocator.permissionRequests, 1);
    });

    test('fails when the user denies the permission', () async {
      geolocator
        ..permission = LocationPermission.denied
        ..permissionAfterRequest = LocationPermission.denied;

      final result = await repository.getCurrentLocation();

      expect(_reasonOf(result), CurrentLocationFailure.permissionDenied);
    });

    test('fails without asking again when the permission is blocked', () async {
      geolocator.permission = LocationPermission.deniedForever;

      final result = await repository.getCurrentLocation();

      expect(_reasonOf(result), CurrentLocationFailure.permissionDeniedForever);
      expect(geolocator.permissionRequests, 0);
    });

    test('fails when the GPS gets no fix within the time limit', () async {
      geolocator.positionError = TimeoutException('sin señal');

      final result = await repository.getCurrentLocation();

      expect(_reasonOf(result), CurrentLocationFailure.timeout);
    });

    test('fails when the GPS is turned off while reading', () async {
      geolocator.positionError = const LocationServiceDisabledException();

      final result = await repository.getCurrentLocation();

      expect(_reasonOf(result), CurrentLocationFailure.serviceDisabled);
    });
  });
}

Object? _reasonOf(Result<CurrentLocation> result) {
  if (result case Failure<CurrentLocation>(:final error)) {
    return error.reason;
  }
  return null;
}

/// Reemplaza al plugin nativo. Se inyecta por constructor, así que no hace
/// falta registrarlo como `GeolocatorPlatform.instance`.
class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission permissionAfterRequest = LocationPermission.whileInUse;
  Exception? positionError;
  int permissionRequests = 0;
  Duration? requestedTimeLimit;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    permissionRequests += 1;
    return permissionAfterRequest;
  }

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    requestedTimeLimit = locationSettings?.timeLimit;
    if (positionError case final error?) {
      throw error;
    }
    return Position(
      latitude: -32.1234,
      longitude: -63.5678,
      accuracy: 6,
      timestamp: DateTime(2026, 10, 8),
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}
