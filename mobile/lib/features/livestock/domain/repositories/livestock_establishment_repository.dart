import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';

/// Contrato para consultar el alcance ganadero disponible sin conexión.
abstract class LivestockEstablishmentRepository {
  /// Lee los establecimientos guardados para la sesión actual.
  Future<Result<List<LivestockEstablishment>>> getEstablishments();
}
