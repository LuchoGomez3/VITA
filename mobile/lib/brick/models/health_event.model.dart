import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

/// Evento individual de Sanidad en SQLite.
@ConnectOfflineFirstWithRest()
class BrickHealthEventModel extends OfflineFirstWithRestModel {
  /// Construye una fila histórica.
  BrickHealthEventModel({
    required this.localId,
    required this.establishmentId,
    required this.animalId,
    required this.payload,
  });

  /// UUID estable del evento.
  @Sqlite(unique: true)
  final String localId;

  /// Establecimiento del evento.
  final String establishmentId;

  /// Animal al que corresponde el evento.
  final String animalId;

  /// Representación serializada del evento individual.
  final String payload;
}
