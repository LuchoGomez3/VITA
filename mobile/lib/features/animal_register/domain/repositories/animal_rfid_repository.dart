import 'package:frontend_mayoral/core/result/result.dart';

/// Consulta la disponibilidad local de una caravana RFID para una nueva alta.
abstract class AnimalRfidRepository {
  /// Busca en todos los establecimientos guardados, incluidos animales pendientes.
  Future<Result<bool>> isRegistered(String rfid);
}
