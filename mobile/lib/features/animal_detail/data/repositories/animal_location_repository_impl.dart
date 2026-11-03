import 'dart:async';

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/utils/coalesced_task.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_location.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_location_repository.dart';
import 'package:logging/logging.dart';

/// Proyecta cambios ya persistidos a una ubicación sin cargar foto ni pesajes.
class AnimalLocationRepositoryImpl implements AnimalLocationRepository {
  /// Conecta los stores locales y el canal genérico de cambios postcommit.
  const AnimalLocationRepositoryImpl({
    required AnimalBrickStore animalStore,
    required LotBrickStore lotStore,
    required Stream<Type> localChanges,
  }) : _animalStore = animalStore,
       _lotStore = lotStore,
       _localChanges = localChanges;

  final AnimalBrickStore _animalStore;
  final LotBrickStore _lotStore;
  final Stream<Type> _localChanges;
  static final _logger = Logger('AnimalLocationRepository');

  @override
  Stream<Result<AnimalLocation?>> watchLocation(String animalId, {required String establishmentId}) =>
      Stream<Result<AnimalLocation?>>.multi((controller) {
        var cancelled = false;
        var revision = 0;
        final reload = CoalescedTask(() async {
          final readingRevision = revision;
          final result = await _readLocation(animalId, establishmentId);
          if (!cancelled && readingRevision == revision) controller.add(result);
        });
        final subscription = _localChanges.where((type) => type == BrickAnimalModel || type == BrickLotModel).listen((
          _,
        ) {
          revision++;
          unawaited(reload.run());
        });
        controller.onCancel = () {
          cancelled = true;
          reload.close();
          unawaited(subscription.cancel());
        };
        unawaited(reload.run());
      }).distinct();

  Future<Result<AnimalLocation?>> _readLocation(String animalId, String establishmentId) async {
    try {
      final animal = await _animalStore.getAnimalById(animalId);
      if (animal == null || animal.establishmentId != establishmentId) return const Result.success(null);
      final lots = await _lotStore.getLocalLots(establishmentId);
      final lot = lots.where((lot) => lot.localId == animal.lotId).firstOrNull;
      return Result.success(
        AnimalLocation(
          animalId: animal.localId,
          establishmentId: animal.establishmentId,
          lotId: animal.lotId,
          lotName: animal.lotId.isEmpty ? '' : lot?.name ?? animal.lotName,
          updatedAt: animal.updatedAt,
        ),
      );
    } on Object catch (error, stackTrace) {
      _logger.warning('Local animal location read failed.', error, stackTrace);
      return const Result.failure(DomainException(message: 'animal_location_read_failed'));
    }
  }
}
