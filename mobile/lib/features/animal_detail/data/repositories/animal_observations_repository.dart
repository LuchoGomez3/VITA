import 'dart:async';

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_observation.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_observation_brick_store.dart';
import 'package:frontend_mayoral/core/utils/coalesced_task.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/animal_observations.dart';
import 'package:logging/logging.dart';

/// Mantiene las observaciones disponibles desde SQLite mientras se sincronizan.
class AnimalObservationsRepository implements AnimalObservationRepository {
  /// Conecta el store y las notificaciones postcommit de Brick.
  const AnimalObservationsRepository(this._store, this._changes);

  final AnimalObservationBrickStore _store;
  final Stream<Type> _changes;
  static final _logger = Logger('AnimalObservationsRepository');

  @override
  Stream<List<AnimalObservation>> watch(String establishmentId, String animalId) =>
      Stream<List<AnimalObservation>>.multi((controller) {
        var cancelled = false;
        final reload = CoalescedTask(() async {
          try {
            final notes = await _store.getLocalObservations(establishmentId, animalId);
            if (!cancelled) {
              controller.add([
                for (final note in notes)
                  (
                    text: note.text,
                    date: note.date,
                    status: switch (note.syncStatus) {
                      BrickAnimalSyncStatus.pending => AnimalSyncStatus.pending,
                      BrickAnimalSyncStatus.synchronized => AnimalSyncStatus.synchronized,
                      BrickAnimalSyncStatus.rejected => AnimalSyncStatus.rejected,
                    },
                  ),
              ]);
            }
          } on Exception catch (error, stackTrace) {
            if (!cancelled) controller.addError(error, stackTrace);
          }
        });
        final subscription = _changes.where((type) => type == BrickAnimalObservationModel).listen((_) {
          unawaited(reload.run());
        });
        controller.onCancel = () {
          cancelled = true;
          reload.close();
          unawaited(subscription.cancel());
        };
        unawaited(reload.run());
        unawaited(_pull(establishmentId, animalId));
      });

  Future<void> _pull(String establishmentId, String animalId) async {
    try {
      await _store.pullObservations(establishmentId, animalId);
    } on Exception catch (error) {
      _logger.fine('Se conserva el historial local de observaciones.', error);
    }
  }

  @override
  Future<void> add(String establishmentId, String animalId, String text) async {
    final now = DateTime.now().toUtc();
    await _store.addObservation(
      BrickAnimalObservationModel(
        localId: generateUuidV4(),
        establishmentId: establishmentId,
        animalId: animalId,
        text: text.trim(),
        date: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
