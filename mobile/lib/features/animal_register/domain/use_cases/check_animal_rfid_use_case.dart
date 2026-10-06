import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_rfid_repository.dart';

/// Comprueba offline si la caravana ya pertenece a un animal registrado.
class CheckAnimalRfidUseCase {
  /// Crea el caso de uso con la consulta local.
  const CheckAnimalRfidUseCase(this._repository);

  final AnimalRfidRepository _repository;

  /// Devuelve true cuando el RFID ya está guardado en el dispositivo.
  Future<Result<bool>> call(String rfid) => _repository.isRegistered(rfid);
}
