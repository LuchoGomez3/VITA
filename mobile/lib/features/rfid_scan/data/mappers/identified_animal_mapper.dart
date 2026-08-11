import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';

/// Convierte el modelo Brick local al resultado liviano de identificacion.
class IdentifiedAnimalMapper {
  const IdentifiedAnimalMapper._();

  /// Crea el modelo que necesita la tarjeta a partir del animal almacenado.
  static IdentifiedAnimal fromBrick(BrickAnimalModel model) {
    return IdentifiedAnimal(
      id: model.localId,
      rfidTagNumber: model.rfidTagNumber,
      visualTag: model.visualTag,
      sex: switch (model.sex) {
        BrickAnimalSex.male => IdentifiedAnimalSex.male,
        BrickAnimalSex.female => IdentifiedAnimalSex.female,
      },
      breed: model.breed,
      categoryName: model.categoryName,
      lotName: model.lotName,
      updatedAt: model.updatedAt,
    );
  }
}
