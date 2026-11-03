import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/weighing/domain/entities/animal_weighing.dart';
import 'package:frontend_mayoral/features/weighing/domain/repositories/weighing_repository.dart';

/// Valida y registra el pesaje de un animal.
///
/// Funciona sin conexión: se guarda en el celular y se sincroniza después.
class RecordAnimalWeighingUseCase {
  /// Crea el caso de uso con identificador y reloj inyectables.
  const RecordAnimalWeighingUseCase({
    required WeighingRepository repository,
    required String Function() createId,
    DateTime Function()? now,
  }) : _repository = repository,
       _createId = createId,
       _now = now;

  /// Peso máximo aceptado, en kg. Un toro adulto ronda los 1.200 kg: un valor
  /// mayor es casi seguro un error de tipeo.
  static const maxWeightKg = 2000.0;

  final WeighingRepository _repository;
  final String Function() _createId;
  final DateTime Function()? _now;

  /// Registra [weightKg] para [animalId].
  Future<Result<AnimalWeighing>> call({
    required String establishmentId,
    required String animalId,
    required double weightKg,
    required AnimalWeighingSource source,
  }) async {
    if (weightKg <= 0 || weightKg > maxWeightKg) {
      return const Result.failure(
        DomainException(
          message: 'Ingresá un peso entre 1 y 2000 kg.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    return _repository.save(
      AnimalWeighing(
        id: _createId(),
        establishmentId: establishmentId,
        animalId: animalId,
        weightKg: weightKg,
        date: (_now?.call() ?? DateTime.now()).toUtc(),
        source: source,
      ),
    );
  }
}
