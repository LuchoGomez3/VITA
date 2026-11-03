import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_animal_lookup_repository.dart';

/// Busca coincidencias locales mientras se ingresa una caravana manualmente.
class SearchAnimalsByRfidPrefixUseCase {
  /// Crea el caso de uso con el repositorio offline de identificacion.
  const SearchAnimalsByRfidPrefixUseCase(this._repository);

  final RfidAnimalLookupRepository _repository;

  /// Devuelve animales del establecimiento cuya caravana inicia con el prefijo.
  Future<Result<List<IdentifiedAnimal>>> call({
    required String rfidPrefix,
    required String establishmentId,
  }) {
    return _repository.findByRfidPrefix(
      rfidPrefix: rfidPrefix,
      establishmentId: establishmentId,
    );
  }
}
