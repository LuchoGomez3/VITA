import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';

/// Reintenta la sincronizacion de un alta de animal rechazada.
class RetryAnimalSyncUseCase {
  /// Crea el caso de uso con el repositorio de detalle.
  const RetryAnimalSyncUseCase(this._repository);

  final AnimalDetailRepository _repository;

  /// Deja el animal pendiente y vuelve a encolar su alta.
  Future<Result<void>> call(String animalId) => _repository.retrySync(animalId);
}
