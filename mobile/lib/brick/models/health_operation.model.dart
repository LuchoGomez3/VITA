import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

/// Envío sanitario durable, independiente de la cola HTTP de Brick.
@ConnectOfflineFirstWithRest()
class BrickHealthOperationModel extends OfflineFirstWithRestModel {
  /// Construye una entrada persistible de la cola sanitaria.
  BrickHealthOperationModel({
    required this.localId,
    required this.establishmentId,
    required this.authorId,
    required this.createdAt,
    required this.payload,
    this.resultEventId,
    this.rejection,
  });

  /// UUID que backend usa para reconocer reenvíos.
  @Sqlite(unique: true)
  final String localId;

  /// Establecimiento de la mutación.
  final String establishmentId;

  /// Cuenta que puede sincronizar o corregir el envío.
  final String authorId;

  /// Fecha de guardado local.
  final DateTime createdAt;

  /// Solicitud original, conservada durante los reintentos.
  final String payload;

  /// Evento objetivo cuando la operación completa un resultado.
  final String? resultEventId;

  /// Código del backend. Nulo mientras la operación puede enviarse.
  final String? rejection;
}
