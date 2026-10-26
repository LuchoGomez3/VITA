import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/weighing/domain/entities/animal_weighing.dart';
import 'package:frontend_mayoral/features/weighing/domain/repositories/weighing_repository.dart';
import 'package:logging/logging.dart';

/// Guarda pesajes con Brick: primero en SQLite y después en la cola de sync.
class WeighingRepositoryImpl implements WeighingRepository {
  /// Crea el repositorio sobre el store de pesajes.
  WeighingRepositoryImpl({required PesajeBrickStore pesajeStore}) : _pesajeStore = pesajeStore;

  static final _logger = Logger('WeighingRepositoryImpl');

  final PesajeBrickStore _pesajeStore;

  @override
  Future<Result<AnimalWeighing>> save(AnimalWeighing weighing) async {
    try {
      await _pesajeStore.upsertPesaje(
        BrickPesajeModel(
          localId: weighing.id,
          establishmentId: weighing.establishmentId,
          animalId: weighing.animalId,
          weightKg: weighing.weightKg,
          date: weighing.date,
          createdAt: weighing.date,
          updatedAt: weighing.date,
          method: switch (weighing.source) {
            AnimalWeighingSource.manual => BrickPesajeMethod.manual,
            AnimalWeighingSource.bluetoothScale => BrickPesajeMethod.bluetoothScale,
          },
        ),
      );
      return Result.success(weighing);
    } on Object catch (error, stackTrace) {
      // Es una operación crítica en la manga: se registra el detalle y se le
      // muestra al productor un mensaje que puede entender.
      _logger.severe('No se pudo guardar el pesaje ${weighing.id}', error, stackTrace);
      return const Result.failure(
        DomainException(message: 'No se pudo guardar el pesaje. Probá de nuevo.'),
      );
    }
  }
}
