import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/initial_data_sync_repository.dart';

/// Caso de uso que prepara datos offline despues del login.
class PrepareInitialDataSyncUseCase {
  /// Crea el caso de uso con el repositorio de sync inicial.
  const PrepareInitialDataSyncUseCase(this._repository);

  final InitialDataSyncRepository _repository;

  /// Ejecuta la sincronizacion inicial para [userId].
  Future<Result<void>> call(String userId) {
    return _repository.syncForUser(userId);
  }
}
