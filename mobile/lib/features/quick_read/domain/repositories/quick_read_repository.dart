import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';

/// Lo que el lector de caravanas necesita leer del celular.
abstract interface class QuickReadRepository {
  /// Animales activos con esa caravana (RFID o visual), buscando en cada
  /// establecimiento del usuario. El RFID es único, pero una caravana visual
  /// puede repetirse entre campos: por eso devuelve una lista.
  Future<Result<List<QuickReadAnimal>>> findByTag(String tag);

  /// Si hay un animal no borrado con el RFID [rfidTagNumber], esté activo o
  /// no (vendido, muerto, sin potrero): ese RFID ya no se puede dar de alta.
  Future<Result<bool>> isRfidRegistered(String rfidTagNumber);

  /// El animal [animalId] actualizado; `null` si ya no está activo.
  Future<Result<QuickReadAnimal?>> getAnimal(String animalId);

  /// Establecimientos del usuario (para elegir el campo de un alta).
  Future<Result<List<EstablishmentMembership>>> getEstablishments();
}
