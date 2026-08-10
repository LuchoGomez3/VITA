import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_animal_lookup_repository.dart';

/// Busca localmente el animal asociado a una caravana electronica.
class FindAnimalByRfidUseCase {
  /// Crea el caso de uso con el contrato de consulta offline.
  const FindAnimalByRfidUseCase(this._repository);

  final RfidAnimalLookupRepository _repository;

  /// Devuelve un modelo liviano para la tarjeta del animal, si existe en SQLite.
  Future<Result<IdentifiedAnimal?>> call({
    required String rfidTagNumber,
    required String establishmentId,
  }) {
    return _repository.findByRfidTagNumber(
      rfidTagNumber: rfidTagNumber,
      establishmentId: establishmentId,
    );
  }
}
