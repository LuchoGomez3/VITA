import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

/// Instantánea local del catálogo y del avance de la descarga de eventos.
@ConnectOfflineFirstWithRest()
class BrickHealthCatalogModel extends OfflineFirstWithRestModel {
  /// Construye la fila del establecimiento.
  BrickHealthCatalogModel({required this.establishmentId, this.payload, this.cursor});

  /// UUID del establecimiento.
  @Sqlite(unique: true)
  final String establishmentId;

  /// Catálogo descargado, serializado por el adaptador de Sanidad.
  final String? payload;

  /// Último cursor aplicado junto con sus eventos.
  final String? cursor;
}
