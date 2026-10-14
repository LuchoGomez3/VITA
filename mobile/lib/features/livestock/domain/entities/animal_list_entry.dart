import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal_list_entry.freezed.dart';

/// Un animal tal como se muestra en la lista de Hacienda.
///
/// Se arma con los datos guardados en el celular (animal, último pesaje,
/// categoría y potrero), así la lista funciona sin conexión.
@freezed
sealed class AnimalListEntry with _$AnimalListEntry {
  /// Crea una fila de la lista de animales.
  const factory AnimalListEntry({
    /// UUID del animal, para abrir su ficha.
    required String id,

    /// Establecimiento al que pertenece, para filtrar la lista.
    required String establishmentId,

    /// Número de caravana visual.
    required String visualTag,

    /// Número RFID oficial (15 dígitos).
    required String rfidTagNumber,

    /// Raza declarada.
    required String breed,

    /// Nombre de la categoría productiva, o vacío si no se conoce.
    required String categoryName,

    /// Nombre del potrero actual, o vacío si no tiene.
    required String lotName,

    /// Último peso conocido en kg, si hay alguno.
    double? lastWeightKg,

    /// Fecha del último peso conocido.
    DateTime? lastWeighingDate,
  }) = _AnimalListEntry;
}
