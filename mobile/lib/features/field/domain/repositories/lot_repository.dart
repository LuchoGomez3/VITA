import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';

/// Contrato offline para almacenar y consultar lotes.
abstract class LotRepository {
  /// Guarda una copia durable local sin depender de la red.
  Future<Result<Lot>> saveLot(Lot lot);

  /// Lista los lotes activos de un único establecimiento.
  Future<Result<List<Lot>>> getLots(String establishmentId);

  /// Obtiene un lote activo por UUID.
  Future<Result<Lot>> getLot(String lotId);
}
