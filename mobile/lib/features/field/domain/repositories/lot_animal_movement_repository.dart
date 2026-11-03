import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';

/// Contrato atómico del cambio local de ubicación de animales.
abstract class LotAnimalMovementRepository {
  /// Actualiza los animales y registra [movement] de forma durable.
  Future<Result<LotAnimalMovement>> moveAnimals(LotAnimalMovement movement);
}
