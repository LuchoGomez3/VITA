import 'package:freezed_annotation/freezed_annotation.dart';

part 'identified_animal.freezed.dart';

/// Sexo del animal mostrado en el resultado de una identificacion RFID.
enum IdentifiedAnimalSex {
  /// Animal macho.
  male,

  /// Animal hembra.
  female,
}

/// Datos minimos para confirmar visualmente el animal identificado.
///
/// La tarjeta usa este modelo liviano y no necesita cargar la ficha completa,
/// sus pesajes ni su historial de eventos.
@freezed
sealed class IdentifiedAnimal with _$IdentifiedAnimal {
  /// Crea la representacion de un animal encontrado en SQLite.
  const factory IdentifiedAnimal({
    /// UUID local y remoto del animal.
    required String id,

    /// Numero oficial de la caravana electronica.
    required String rfidTagNumber,

    /// Numero de caravana visual mostrado en campo.
    required String visualTag,

    /// Sexo declarado del animal.
    required IdentifiedAnimalSex sex,

    /// Raza declarada del animal.
    required String breed,

    /// Nombre visible de la categoria productiva.
    required String categoryName,

    /// Nombre visible del lote actual.
    required String lotName,

    /// Ultima actualizacion conocida en la base local.
    required DateTime updatedAt,
  }) = _IdentifiedAnimal;
}
