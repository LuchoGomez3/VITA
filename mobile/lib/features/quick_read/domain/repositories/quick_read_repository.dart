import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';

/// Lo que el lector de caravanas necesita leer del celular.
abstract interface class QuickReadRepository {
  /// Animal activo con esa caravana (RFID o visual); `null` si no hay.
  Future<Result<QuickReadAnimal?>> findByTag(String tag);

  /// El animal [animalId] actualizado; `null` si ya no está activo.
  Future<Result<QuickReadAnimal?>> getAnimal(String animalId);

  /// Establecimientos del usuario (para elegir el campo de un alta).
  Future<Result<List<EstablishmentMembership>>> getEstablishments();
}
