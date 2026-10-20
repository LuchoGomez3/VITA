import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/current_location.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/repositories/current_location_repository.dart';

/// Caso de uso para leer la ubicación actual del dispositivo.
class GetCurrentLocationUseCase {
  /// Crea el caso de uso con el repositorio inyectado.
  const GetCurrentLocationUseCase(this._repository);

  final CurrentLocationRepository _repository;

  /// Ejecuta la lectura delegando en el repositorio.
  Future<Result<CurrentLocation>> call() {
    return _repository.getCurrentLocation();
  }
}
