import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal_registration.freezed.dart';

/// Sexo del animal dentro del dominio mobile.
///
/// Se mantiene independiente del valor textual que espera el backend. La
/// traduccion a `macho` / `hembra` se hace en la frontera de mapper/REST.
enum AnimalSex {
  /// Animal macho.
  male,

  /// Animal hembra.
  female,
}

/// Metodo usado para obtener el peso inicial del animal.
///
/// El registro de animal incluye el primer pesaje, por eso el dominio guarda
/// tanto el peso como la forma en la que fue capturado.
enum AnimalWeighingMethod {
  /// Peso ingresado manualmente.
  manual,

  /// Peso recibido desde una balanza Bluetooth.
  bluetoothScale,

  /// Peso estimado por un modelo local en el dispositivo.
  artificialIntelligence,
}

/// Estado de sincronizacion del animal guardado en el dispositivo.
///
/// Este estado es local de mobile: indica que paso con la sincronizacion entre
/// SQLite/Brick y el backend, no el estado productivo del animal en el campo.
enum AnimalSyncStatus {
  /// Guardado localmente y pendiente de llegar al backend.
  pending,

  /// Confirmado por el backend.
  synchronized,

  /// Rechazado por el backend y pendiente de revision del usuario.
  rejected,
}

/// Helpers para traducir [AnimalSex] al contrato textual del backend.
extension AnimalSexBackendValue on AnimalSex {
  /// Valor compatible con el enum de sexo usado por el backend.
  String get backendValue => switch (this) {
    AnimalSex.male => 'macho',
    AnimalSex.female => 'hembra',
  };
}

/// Helpers para traducir [AnimalWeighingMethod] al contrato textual del backend.
extension AnimalWeighingMethodBackendValue on AnimalWeighingMethod {
  /// Valor compatible con el enum de metodo de pesaje usado por el backend.
  String get backendValue => switch (this) {
    AnimalWeighingMethod.manual => 'manual',
    AnimalWeighingMethod.bluetoothScale => 'balanza_bluetooth',
    AnimalWeighingMethod.artificialIntelligence => 'estimacion_ia',
  };
}

/// Datos necesarios para registrar un animal y su pesaje inicial.
///
/// Esta entidad representa la intencion de negocio que sale del formulario. No
/// sabe nada de Brick, SQLite ni JSON: esos detalles se resuelven en data por
/// medio de mappers/adapters.
@freezed
sealed class AnimalRegistration with _$AnimalRegistration {
  /// Crea una solicitud de registro de animal.
  ///
  /// Los IDs (`lotId`, `establishmentId`, `categoryId`, `motherId`, `fatherId`)
  /// deben llegar ya resueltos a IDs reales o temporalmente mockeados por el
  /// contexto de registro. La entidad no deberia resolver catalogos por si
  /// misma.
  const factory AnimalRegistration({
    /// Numero de caravana RFID individual.
    required String rfidTagNumber,

    /// Numero visual de caravana mostrado al usuario.
    required String visualTag,

    /// Sexo del animal.
    required AnimalSex sex,

    /// Raza declarada al momento del alta.
    required String breed,

    /// Fecha de nacimiento del animal.
    required DateTime birthDate,

    /// ID del lote/potrero donde queda ubicado el animal.
    required String lotId,

    /// Nombre visible del lote usado para resumenes de UI.
    required String lotName,

    /// ID del establecimiento al que pertenece el animal.
    required String establishmentId,

    /// ID de la categoria productiva del animal.
    required String categoryId,

    /// Nombre visible de la categoria usado para resumenes de UI.
    required String categoryName,

    /// Peso inicial registrado junto con el alta.
    required double initialWeight,

    /// ID de la madre, cuando se selecciona genealogia.
    String? motherId,

    /// ID del padre, cuando se selecciona genealogia.
    String? fatherId,

    /// Pelaje declarado, si el formulario lo captura.
    String? coat,

    /// Observaciones libres del registro.
    String? observations,

    /// Metodo con el que se obtuvo el peso inicial.
    @Default(AnimalWeighingMethod.manual) AnimalWeighingMethod weighingMethod,

    /// Fecha/hora del pesaje inicial. Si no viene, data puede completar una.
    DateTime? weighingDate,
  }) = _AnimalRegistration;
}

/// Resultado de un registro de animal persistido por el repository.
///
/// A diferencia de [AnimalRegistration], este objeto ya tiene identidad local,
/// timestamps y estado de sincronizacion. Es lo que la UI puede mostrar despues
/// de guardar en modo offline-first.
@freezed
sealed class RegisteredAnimal with _$RegisteredAnimal {
  /// Crea el resultado identificable del registro.
  const factory RegisteredAnimal({
    /// UUID generado en mobile y usado tambien como ID de backend.
    required String id,

    /// Datos de negocio registrados.
    required AnimalRegistration registration,

    /// Estado local de sincronizacion con backend.
    required AnimalSyncStatus syncStatus,

    /// Fecha/hora de creacion local del registro.
    required DateTime createdAt,

    /// Fecha/hora de ultima modificacion de negocio.
    required DateTime updatedAt,

    /// Destino visible para pantallas de exito o resumen.
    required String displayDestination,

    /// Categoria visible para pantallas de exito o resumen.
    required String displayCategory,

    /// Codigo de error devuelto por backend cuando el sync queda rechazado.
    String? syncErrorCode,
  }) = _RegisteredAnimal;
}
