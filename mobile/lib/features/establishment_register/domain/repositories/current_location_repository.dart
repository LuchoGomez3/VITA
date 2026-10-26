import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';

/// Contrato de acceso a la ubicación del dispositivo.
abstract class CurrentLocationRepository {
  /// Lee la posición actual del GPS, pidiendo el permiso si hace falta.
  ///
  /// Los fallos esperables (GPS apagado, permiso negado, sin señal) vuelven
  /// como `Result.failure` con un [CurrentLocationFailure] en `reason`.
  Future<Result<CurrentLocation>> getCurrentLocation();
}
