import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

part 'animal_detail.freezed.dart';

/// Informacion de negocio que necesita la ficha de un animal.
///
/// Se mantiene independiente de Brick y del shape REST para que presentation no
/// dependa de SQLite, HTTP ni nombres de campos del backend.
@freezed
sealed class AnimalDetail with _$AnimalDetail {
  /// Crea el detalle leido desde cache local o backend.
  const factory AnimalDetail({
    /// UUID generado por mobile y usado tambien por backend.
    required String id,

    /// Numero RFID oficial del animal.
    required String rfidTagNumber,

    /// Numero visual de caravana mostrado en UI.
    required String visualTag,

    /// Sexo del animal.
    required AnimalSex sex,

    /// Raza declarada del animal.
    required String breed,

    /// Fecha de nacimiento.
    required DateTime birthDate,

    /// ID backend de la categoria productiva.
    required String categoryId,

    /// Nombre visible de la categoria si existe en cache local.
    required String categoryName,

    /// ID backend del lote/potrero actual.
    required String lotId,

    /// Nombre visible del lote si existe en cache local.
    required String lotName,

    /// ID backend del establecimiento.
    required String establishmentId,

    /// Ultimo peso conocido por la app.
    required double currentWeight,

    /// Metodo asociado al ultimo peso conocido.
    required AnimalWeighingMethod weighingMethod,

    /// Fecha del ultimo pesaje conocido.
    required DateTime weighingDate,

    /// Estado local de sincronizacion con backend.
    required AnimalSyncStatus syncStatus,

    /// Ultima actualizacion conocida.
    required DateTime updatedAt,

    /// ID backend de la madre, si existe.
    String? motherId,

    /// ID backend del padre, si existe.
    String? fatherId,

    /// Pelaje declarado.
    String? coat,

    /// Observaciones libres.
    String? observations,

    /// Codigo de rechazo de sync guardado localmente.
    String? syncErrorCode,
  }) = _AnimalDetail;
}
