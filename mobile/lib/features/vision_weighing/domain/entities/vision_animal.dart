import 'package:freezed_annotation/freezed_annotation.dart';

part 'vision_animal.freezed.dart';

/// Animal local que puede asociarse a una captura durante esta sesión.
@freezed
sealed class VisionAnimal with _$VisionAnimal {
  /// Conserva la identidad estable y las caravanas visibles para el operario.
  const factory VisionAnimal({
    required String id,
    required String establishmentId,
    required String rfidTagNumber,
    required String visualTag,
    required DateTime updatedAt,
  }) = _VisionAnimal;
}

/// Establecimiento disponible para buscar un animal con el bastón.
@freezed
sealed class VisionEstablishment with _$VisionEstablishment {
  /// Vincula el nombre del catálogo offline con su identificador.
  const factory VisionEstablishment({required String id, required String name}) = _VisionEstablishment;
}

/// Datos locales necesarios para elegir un animal sin depender de RFID Scan.
@freezed
sealed class VisionAnimalOptions with _$VisionAnimalOptions {
  /// Presenta animales y establecimientos del mismo dispositivo.
  const factory VisionAnimalOptions({
    required List<VisionAnimal> animals,
    required List<VisionEstablishment> establishments,
  }) = _VisionAnimalOptions;
}
