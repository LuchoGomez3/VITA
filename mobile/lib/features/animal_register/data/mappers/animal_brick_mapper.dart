import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal.dart';

class AnimalBrickMapper {
  static BrickAnimalModel toBrick(Animal animal) {
    return BrickAnimalModel(
      nroCaravana: animal.nroCaravana,
      sexo: animal.sexo,
      raza: animal.raza,
      peso: animal.peso,
      fechaNac: animal.fechaNac,
      idLote: animal.idLote,
      caravanaPadre: animal.caravanaPadre,
      caravanaMadre: animal.caravanaMadre,
      categoria: animal.categoria,
      pelaje: animal.pelaje,
      observaciones: animal.observaciones,
    );
  }

  static Animal toDomain(BrickAnimalModel model) {
    return Animal(
      nroCaravana: model.nroCaravana,
      sexo: model.sexo,
      raza: model.raza,
      peso: model.peso,
      fechaNac: model.fechaNac,
      idLote: model.idLote,
      caravanaPadre: model.caravanaPadre,
      caravanaMadre: model.caravanaMadre,
      categoria: model.categoria,
      pelaje: model.pelaje,
      observaciones: model.observaciones,
    );
  }
}
