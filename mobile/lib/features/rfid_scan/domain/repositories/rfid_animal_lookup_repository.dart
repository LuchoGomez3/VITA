import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';

/// Contrato de busqueda offline de animales por caravana RFID.
abstract class RfidAnimalLookupRepository {
  /// Busca una caravana dentro del establecimiento indicado.
  ///
  /// Un resultado exitoso con `null` indica que la caravana no esta disponible
  /// en la copia local del dispositivo.
  Future<Result<IdentifiedAnimal?>> findByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  });
}
