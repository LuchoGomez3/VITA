import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/initial_data_sync_repository.dart';

/// Caso de uso que prepara datos offline despues del login.
///
/// Es el punto de entrada de presentation hacia la sync inicial. Mantenerlo como
/// caso de uso evita que `LoginBloc` conozca stores Brick, data sources remotos
/// o marcadores de secure storage.
class PrepareInitialDataSyncUseCase {
  /// Crea el caso de uso con el repositorio de sync inicial.
  const PrepareInitialDataSyncUseCase(this._repository);

  final InitialDataSyncRepository _repository;

  /// Ejecuta la sincronizacion inicial para [userId].
  ///
  /// Devuelve [Result.failure] cuando no se pudo preparar offline, pero esa
  /// falla no invalida necesariamente la sesion autenticada.
  Future<Result<void>> call(String userId) {
    return _repository.syncForUser(userId);
  }
}
