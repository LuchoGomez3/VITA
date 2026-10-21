import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:meta/meta.dart';

/// Animal registrado leído en el lector, con su último peso conocido.
@immutable
class QuickReadAnimal {
  /// Crea el animal.
  const QuickReadAnimal({required this.animal, this.lastWeightKg, this.lastWeighingDate});

  /// Datos para moverlo y mostrarlo.
  final MovementAnimal animal;

  /// Último peso conocido.
  final double? lastWeightKg;

  /// Fecha de ese peso.
  final DateTime? lastWeighingDate;

  @override
  bool operator ==(Object other) =>
      other is QuickReadAnimal &&
      other.animal == animal &&
      other.lastWeightKg == lastWeightKg &&
      other.lastWeighingDate == lastWeighingDate;

  @override
  int get hashCode => Object.hash(animal, lastWeightKg, lastWeighingDate);
}

/// Una caravana leída en la sesión del lector.
@immutable
sealed class QuickReadItem {
  const QuickReadItem();
}

/// Caravana de un animal registrado y activo.
final class RegisteredRead extends QuickReadItem {
  /// Crea la lectura.
  const RegisteredRead(this.animal);

  /// Animal leído.
  final QuickReadAnimal animal;

  @override
  bool operator ==(Object other) => other is RegisteredRead && other.animal == animal;

  @override
  int get hashCode => animal.hashCode;
}

/// RFID válido que no está en el celular: se puede dar de alta.
final class UnregisteredRead extends QuickReadItem {
  /// Crea la lectura con los 15 dígitos.
  const UnregisteredRead(this.rfidTagNumber);

  /// RFID de 15 dígitos.
  final String rfidTagNumber;

  @override
  bool operator ==(Object other) => other is UnregisteredRead && other.rfidTagNumber == rfidTagNumber;

  @override
  int get hashCode => rfidTagNumber.hashCode;
}
