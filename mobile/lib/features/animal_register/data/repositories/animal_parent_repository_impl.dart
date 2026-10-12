import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_parent.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_parent_repository.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

/// Consulta los animales guardados en Brick sin realizar requests remotas.
class AnimalParentRepositoryImpl implements AnimalParentRepository {
  /// Crea el repositorio con el store compartido de animales.
  const AnimalParentRepositoryImpl({required AnimalBrickStore store}) : _store = store;

  final AnimalBrickStore _store;
  static final _logger = Logger('AnimalParentRepository');

  @override
  Future<Result<List<AnimalParent>>> getParents(String establishmentId) async {
    try {
      final animals = await _store.getLocalAnimals();
      return Result.success(
        animals
            .where((animal) => animal.establishmentId == establishmentId && animal.deletedAt == null)
            .map(
              (animal) => AnimalParent(
                id: animal.localId,
                visualTag: animal.visualTag,
                rfid: animal.rfidTagNumber,
                breed: animal.breed,
                sex: switch (animal.sex) {
                  BrickAnimalSex.female => AnimalSex.female,
                  BrickAnimalSex.male => AnimalSex.male,
                },
              ),
            )
            .toList(growable: false),
      );
    } on DatabaseException catch (error, stackTrace) {
      _logger.severe('Failed to read local parent animals', error, stackTrace);
      return const Result.failure(
        DomainException(message: 'No se pudieron cargar los animales guardados.'),
      );
    }
  }
}
