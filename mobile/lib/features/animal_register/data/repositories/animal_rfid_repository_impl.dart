import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_rfid_repository.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

/// Consulta duplicados en la caché Brick, sin depender de la conexión.
class AnimalRfidRepositoryImpl implements AnimalRfidRepository {
  /// Crea el repositorio sobre el store local de animales.
  const AnimalRfidRepositoryImpl({required AnimalBrickStore store}) : _store = store;

  final AnimalBrickStore _store;
  static final _logger = Logger('AnimalRfidRepository');

  @override
  Future<Result<bool>> isRegistered(String rfid) async {
    try {
      final animals = await _store.getLocalAnimals();
      return Result.success(
        animals.any((animal) => animal.rfidTagNumber == rfid && animal.deletedAt == null),
      );
    } on DatabaseException catch (error, stackTrace) {
      _logger.severe('Failed to check local RFID availability', error, stackTrace);
      return const Result.failure(
        DomainException(message: 'No se pudo comprobar la caravana en el dispositivo.'),
      );
    }
  }
}
