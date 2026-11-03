import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';

/// Lectura offline de animales necesaria para la gestión de lotes.
abstract class LotAnimalRepository {
  /// Lista animales vigentes del establecimiento y, opcionalmente, un lote.
  Future<Result<List<LotAnimalSummary>>> getAnimals({
    required String establishmentId,
    String? lotId,
  });
}
