import 'package:frontend_mayoral/brick/mappers/latest_weight.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/validators/rfid_validator.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_tag_kind.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';
import 'package:frontend_mayoral/features/quick_read/domain/repositories/quick_read_repository.dart';
import 'package:logging/logging.dart';

/// Busca en el celular reusando la búsqueda de "Mover animales" y le suma el
/// último peso (misma serie que la lista de Hacienda).
class QuickReadRepositoryImpl implements QuickReadRepository {
  /// Crea el repositorio.
  const QuickReadRepositoryImpl({
    required AnimalMovementRepository movementRepository,
    required AnimalBrickStore animalStore,
    required PesajeBrickStore pesajeStore,
    required EstablishmentCatalog establishmentCatalog,
  }) : _movementRepository = movementRepository,
       _animalStore = animalStore,
       _pesajeStore = pesajeStore,
       _establishmentCatalog = establishmentCatalog;

  static final _logger = Logger('QuickReadRepository');

  final AnimalMovementRepository _movementRepository;
  final AnimalBrickStore _animalStore;
  final PesajeBrickStore _pesajeStore;
  final EstablishmentCatalog _establishmentCatalog;

  @override
  Future<Result<List<QuickReadAnimal>>> findByTag(String tag) async {
    final establishments = await getEstablishments();
    if (establishments is Failure<List<EstablishmentMembership>>) {
      return Result.failure(establishments.error);
    }
    final kind = RfidValidator.isValid(tag) ? MovementTagKind.rfid : MovementTagKind.visual;
    final found = <QuickReadAnimal>[];
    for (final establishment in (establishments as Success<List<EstablishmentMembership>>).data) {
      final result = await _withWeight(
        await _movementRepository.findAnimalByTag(
          tag,
          establishmentId: establishment.id,
          kind: kind,
        ),
      );
      switch (result) {
        case Success<QuickReadAnimal?>(:final data):
          if (data != null) found.add(data);
        case Failure<QuickReadAnimal?>(:final error):
          return Result.failure(error);
      }
    }
    return Result.success(found);
  }

  @override
  Future<Result<bool>> isRfidRegistered(String rfidTagNumber) async {
    try {
      final animals = await _animalStore.getLocalAnimals();
      return Result.success(
        animals.any(
          (animal) => animal.deletedAt == null && animal.rfidTagNumber.replaceAll(RegExp(r'\D'), '') == rfidTagNumber,
        ),
      );
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudo buscar el RFID $rfidTagNumber', error, stackTrace);
      return const Result.failure(DomainException(message: 'No se pudo leer la hacienda del celular.'));
    }
  }

  @override
  Future<Result<QuickReadAnimal?>> getAnimal(String animalId) async =>
      _withWeight(await _movementRepository.getAnimal(animalId));

  @override
  Future<Result<List<EstablishmentMembership>>> getEstablishments() async {
    try {
      return Result.success(await _establishmentCatalog.getMemberships());
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudieron leer los establecimientos', error, stackTrace);
      return const Result.failure(DomainException(message: 'No se pudieron leer tus establecimientos.'));
    }
  }

  Future<Result<QuickReadAnimal?>> _withWeight(Result<MovementAnimal?> result) async {
    if (result is Failure<MovementAnimal?>) {
      return Result.failure(result.error);
    }
    final animal = (result as Success<MovementAnimal?>).data;
    if (animal == null) {
      return const Result.success(null);
    }
    try {
      final stored = await _animalStore.getAnimalById(animal.id);
      if (stored == null) {
        return Result.success(QuickReadAnimal(animal: animal));
      }
      final weighings = await _pesajeStore.getLocalPesajesByAnimal(animal.id);
      final latest = latestKnownWeight(stored, latestWeighingByAnimal(weighings)[animal.id]);
      return Result.success(
        QuickReadAnimal(animal: animal, lastWeightKg: latest.weightKg, lastWeighingDate: latest.date),
      );
    } on Object catch (error, stackTrace) {
      // Sin el peso igual se puede actuar sobre el animal.
      _logger.warning('No se pudo leer el último peso de ${animal.id}', error, stackTrace);
      return Result.success(QuickReadAnimal(animal: animal));
    }
  }
}
